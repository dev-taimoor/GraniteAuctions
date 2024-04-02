class Car < ApplicationRecord
  belongs_to :category
  belongs_to :salvage_category

  has_many :auction_cars
  has_many :auctions, through: :auction_cars
  has_many :bids

  has_one_attached :image

  scope :available, -> { where(sold: false) }
  scope :sold_cars, -> { where(sold: true) }
  
  scope :active, -> { where(sold: false) }

  scope :car_by_year, lambda { |years|
    where('year IN (?)', years)
  }

  scope :car_by_category, lambda { |category_ids|
    where('category_id IN (?)', category_ids)
  }


  scope :by_category_name, ->(category_name) {
    joins(:category)
      .where("LOWER(categories.name) = ?", category_name.downcase)
  }

  scope :car_by_salvage_category, lambda { |salvage_ids|
    where('salvage_category_id IN (?)', salvage_ids)
  }

  scope :car_by_make_model, lambda { |makes|
    where(makes.map { |make| "make_model LIKE ?" }.join(" OR "), *makes.map { |make| "%#{make}%" })
  }

  scope :car_by_price_range, ->(price_range) {
    case price_range
    when "< $100,000"
      where("buy_now_price < ?", 100000)
    when "$100,000 - $200,000"
      where(buy_now_price: 100000..200000)
    when "$200,000 - $300,000"
      where(buy_now_price: 200000..300000)
    when "$300,000 - $400,000"
      where(buy_now_price: 300000..400000)
    when ">$400,000"
      where("buy_now_price > ?", 400000)
    else
      all
    end
  }

  def self.apply_filters(params)
    cars = active
    cars = cars.car_by_make_model(Array.wrap(params[:make])) if params[:make].present?
    cars = cars.car_by_year(params[:year]) if params[:year].present?
    cars = cars.car_by_category(params[:category]) if params[:category].present?
    cars = cars.car_by_salvage_category(params[:salvage]) if params[:salvage].present?
    cars = cars.car_by_price_range(params[:price_range]) if params[:price_range].present?
    cars = cars.by_category_name(params[:name]) if params[:name].present?
    cars
  end
end

