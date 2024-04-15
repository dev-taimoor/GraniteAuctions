class Car < ApplicationRecord
  belongs_to :category
  belongs_to :salvage_category

  has_many :auction_cars
  has_many :auctions, through: :auction_cars
  has_many :bids

  has_one_attached :image

  validates :make, presence: true
  validates :model, presence: true

  after_create :create_stripe_product
  after_update :update_stripe_price

  scope :available, -> { where(sold: false) }

  scope :sold_cars, -> { where(sold: true) }
  
  scope :active, -> { where(sold: false) }

  scope :car_by_year, lambda { |years|
    where('year IN (?)', years)
  }

  scope :car_by_location, lambda { |location|
    where('location LIKE ?', location)
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

  scope :car_by_make_model, ->(makes) {
    where(
      makes.map { |_make| "make LIKE ?" }.join(' OR '), *makes.map { |make| "%#{make}%" }
      )
  }

  scope :car_by_model, ->(models) {
    where(
      models.map { |_model| "model LIKE ?" }.join(' OR '), *models.map { |model| "%#{model}%" }
      )
  }

  scope :car_by_price_range, ->(price_range) {
    case price_range
    when "< £2500"
      where("buy_now_price < ?", 2500)
    when "£2501 - £5000"
      where(buy_now_price: 2501..5000)
    when "£5001 - £10,000"
      where(buy_now_price: 5001..10000)
    when "£10,001 - £20,000"
      where(buy_now_price: 10001..20000)
    when ">£20,001"
      where("buy_now_price > ?", 20001)
    else
      all
    end
  }

  scope :in_progress_auction_cars, -> { joins(:auctions).where(auctions: { status: 'in_progress' }) }

  def self.apply_filters(params)
    cars = active
    cars = cars.car_by_make_model(Array.wrap(params[:make])) if params[:make].present?
    cars = cars.car_by_model(Array.wrap(params[:model])) if params[:model].present?
    cars = cars.car_by_year(params[:year]) if params[:year].present?
    cars = cars.car_by_category(params[:category]) if params[:category].present?
    cars = cars.car_by_salvage_category(params[:salvage]) if params[:salvage].present?
    cars = cars.car_by_price_range(params[:price_range]) if params[:price_range].present?
    cars = cars.car_by_location(params[:city]) if params[:city].present?
    cars = cars.by_category_name(params[:name]) if params[:name].present?
    cars
  end

  def auction_end_time
    auctions.current.first.end_time
  end

  def create_stripe_product
    stripe_product = Stripe::Product.create({
      name: "#{make}, #{model}",
      description: description,
      default_price_data: {
        currency: "gbp",
        unit_amount: calculate_final_price_in_cents.to_i
      },
      metadata: {
        car_id: id,
      }
    })
    update(stripe_product_id: stripe_product.id, stripe_price_id: stripe_product.default_price)
  end

  def update_stripe_price
    if saved_change_to_buy_now_price? || saved_change_to_delivery_cost?
      Stripe::Price.update(stripe_price_id,{
        unit_amount: calculate_final_price_in_cents
      })
    end
  end

  def calculate_final_price_in_cents
    (buy_now_price + (0.2 * buy_now_price) + delivery_cost) * 100
  end
end

