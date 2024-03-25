class Bid < ApplicationRecord
  belongs_to :car
  belongs_to :auction
end
