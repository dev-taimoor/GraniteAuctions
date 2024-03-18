class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :user_name, uniqueness: true
  validates :email, uniqueness: true

  has_one_attached :verification_image1
  has_one_attached :verification_image2

  enum role: { dealer: 'dealer', individual: 'individual', admin: 'admin' }

  def verification_completed?
    role == 'admin' || (role == "individual" && verification_image1.attached? && verification_image2.attached?) || (role == "dealer" && verification_image1.attached? && verification_image2.attached? && business_name.present? && vat_number.present? && breakers_licencing.present?)
  end
end
