class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_name, presence: true, uniqueness: true

  has_one :stripe_account_detail
  has_one_attached :verification_image1
  has_one_attached :verification_image2
  has_one_attached :image

  has_many :receipts
  has_many :bids

  after_create :create_stripe_account

  enum role: { dealer: 'dealer', individual: 'individual', admin: 'admin' }
  enum admin_status: { pending: 'pending', rejected: 'rejected', approved: 'approved' }

  def address
    "#{address_line_1} #{address_line_2}, #{city}, #{state}, #{country}"
  end

  def get_revenue
    user_revenue = Receipt.where(user_id: id, created_at: 6.months.ago.beginning_of_month..Time.current.end_of_month)
                        .group("strftime('%m %Y', created_at)")
                        .sum(:amount)
    user_stat_data = {}

    (0..5).reverse_each do |i|
      month_year_key = (Time.current - i.month).strftime('%B')
      month_year_value = (Time.current - i.month).strftime('%m %Y')
      user_stat_data[month_year_key] = user_revenue[month_year_value] || 0
    end
    user_stat_data
  end

  def verification_completed?
    role == 'admin' ||
    (role == "individual" && verification_image1.attached? && verification_image2.attached? && stripe_account_detail.payment_status) ||
    (role == "dealer" && verification_image1.attached? && verification_image2.attached? && business_name.present? && vat_number.present? && breakers_licensing.present?)
  end

  private

  def create_stripe_account
    Stripe::AccountCreationService.new(self.id).account_creation
  end
end
