class AuctionCar < ApplicationRecord
  belongs_to :auction
  belongs_to :car

  validate :unique_car_for_active_auction

  def unique_car_for_active_auction
    if car.auctions.where.not(status: 'completed').exists?
      errors.add(:base, "The car is already associated with an active auction")
    end
  end
end
