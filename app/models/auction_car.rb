class AuctionCar < ApplicationRecord
  belongs_to :auction
  belongs_to :car
end
