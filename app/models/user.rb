class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_name, presence: true, uniqueness: true

  has_one_attached :verification_image1
  has_one_attached :verification_image2
  has_one_attached :image

  enum role: { dealer: 'dealer', individual: 'individual', admin: 'admin' }
  enum admin_status: { pending: 'pending', rejected: 'rejected', approved: 'approved' }

  def verification_completed?
    role == 'admin' || (role == "individual" && verification_image1.attached? && verification_image2.attached?) || (role == "dealer" && verification_image1.attached? && verification_image2.attached? && business_name.present? && vat_number.present? && breakers_licensing.present?)
  end
end
