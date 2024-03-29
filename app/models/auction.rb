class Auction < ApplicationRecord
  has_many :auction_cars
  has_many :cars, through: :auction_cars
  has_many :bids

  scope :current, -> { where(status: "in_progress") }
  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(sold: "completed") }

  def remove_car(car)
    self.cars.delete(car)
  end
end
