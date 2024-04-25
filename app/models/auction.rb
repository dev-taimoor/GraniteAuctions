class Auction < ApplicationRecord
  has_many :auction_cars
  has_many :cars, through: :auction_cars
  has_many :bids

  scope :current, -> { where(status: "in_progress") }
  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  scope :completed_not_updated, -> { current.where('end_time < ?', Time.now) }

  def remove_car(car)
    self.cars.delete(car)
  end
end
