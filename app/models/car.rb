class Car < ApplicationRecord
  belongs_to :category
  belongs_to :salvage_category

  has_many :auction_cars
  has_many :auctions, through: :auction_cars
  has_many :bids

  has_one_attached :image
  
end