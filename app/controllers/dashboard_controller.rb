class DashboardController < ApplicationController
  before_action :ensure_admin

  def index
    start_date = params[:start_date]
    end_date = params[:end_date]

    if start_date.present? && end_date.present?
      @cars_listed = Car.where(created_at: start_date...end_date).count
      @cars_sold = Car.where(sold: true, updated_at: start_date...end_date).count
      @revenue = Receipt.where(created_at: start_date...end_date).sum(:amount)
      @auction_end = Auction.where(end_time: start_date...end_date).minimum(:end_time)&.strftime("%H:%M:%S") || "00:00:00"
    else
      @cars_listed = Car.all.count
      @auction_end = Auction.current.minimum(:end_time).strftime("%H:%M:%S") rescue "00:00:00"
      @cars_sold = Car.sold_cars.count
      @revenue = Receipt.all.sum(:amount)
    end
    @cars_available = Car.available.count

    revenue_data = Receipt.where(created_at: 11.months.ago.beginning_of_month..Time.current.end_of_month)
                        .group("strftime('%m %Y', created_at)")
                        .sum(:amount)
    @all_months_data = {}

    (0..11).reverse_each do |i|
      month_year_key = (Time.current - i.month).strftime('%B')
      month_year_value = (Time.current - i.month).strftime('%m %Y')
      @all_months_data[month_year_key] = revenue_data[month_year_value] || 0
    end

    @cars_analytics = { "Sold"=> @cars_sold , "In stock"=> @cars_available  }
    @top_sold_cars = Car.joins(:receipt).where(sold: true).order("receipts.amount DESC").limit(2)

    @recent_orders = Car.sold_cars.order("updated_at DESC").limit(4)

    category_avg_prices = Category.left_joins(:cars).group(:name).select("categories.name AS category_name, COALESCE(AVG(cars.buy_now_price), 0) AS avg_price").map(&:attributes)
    @category_avg_prices_hash = {}
    category_avg_prices.each do |category|
      @category_avg_prices_hash[category["category_name"]] = category["avg_price"].round(2)
    end

    salvage_category_avg_prices = SalvageCategory.left_joins(:cars).group(:name).select("salvage_categories.name AS salvage_category_name, COALESCE(AVG(cars.buy_now_price), 0) AS avg_price").map(&:attributes)
    @salvage_category_avg_prices_hash = {}
    salvage_category_avg_prices.each do |category|
      @salvage_category_avg_prices_hash[category["salvage_category_name"]] = category["avg_price"].round(2)
    end

    categories_count = Category.left_joins(:cars).group(:name).select("categories.name AS category_name, COUNT(cars.id) AS cars_count").map(&:attributes)
    @category_stat = {}
    categories_count.each do |category|
      @category_stat[category["category_name"]] = category["cars_count"].to_i
    end
    @users = User.all.paginate(page: params[:user], per_page: 4)

  end

  def ensure_admin
    authorize! :manage, Auction
  end
end
