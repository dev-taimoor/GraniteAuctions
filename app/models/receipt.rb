class Receipt < ApplicationRecord
  belongs_to :car, optional: true
  belongs_to :user

  scope :created_today, -> { where(created_at: Time.zone.now.all_day) }
end
