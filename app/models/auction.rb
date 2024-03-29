class Auction < ApplicationRecord
  has_many :auction_cars
  has_many :cars, through: :auction_cars
  has_many :bids
end
