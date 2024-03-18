class Car < ApplicationRecord
  belongs_to :category
  belongs_to :salvage_category

  has_one_attached :image
  
end