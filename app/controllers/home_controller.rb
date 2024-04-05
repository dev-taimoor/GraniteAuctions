class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_cars, only: %i[car_search]
  def index
    if user_signed_in?
      if current_user.admin?
        redirect_to dashboard_path
      else
        redirect_to car_collection_path
      end
    end
  end

  def car_collection
    @vehicle_types = car_filter_types
    @make_model = Car.all.pluck(:make_model).uniq
    per_page_items = request.user_agent =~ /Mobile|webOS/ ? 4 : 8
    @cars = Car.active.paginate(page: params[:page], per_page: per_page_items)
  end

  def car_search
    set_breadcrumbs
    set_filters
    per_page_items = request.user_agent =~ /Mobile|webOS/ ? 8 : 9
    @filterd_cars = @available_vehicles.apply_filters(params)&.paginate(page: params[:page], per_page: per_page_items)
  end

  private

  def set_breadcrumbs
    @breadcrumbs = [{ text: "Home", url: root_path }, { text: "Used Cars", url: car_collection_path }, { text: "User Cars For Sale in #{params[:city]}", url: car_search_path }]
  end

  def set_filters
    @years = @available_vehicles.all.pluck(:year).uniq
    @makes = @available_vehicles.all.pluck(:make_model).uniq
    @categories = Category.all.pluck(:id, :name)
    @salvage_categories = SalvageCategory.all.pluck(:id, :name)
    @models = ['Toyota']
  end

  def set_cars
    @available_vehicles = Car.active
  end

  def search_params
    params.permit(:city, :make, :year, :category, :salvage_category, :model)
  end

  def car_filter_types
    [
      { name: "Convertible", icon: "covertible.svg" },
      { name: "Coupe", icon: "coupe.svg" },
      { name: "Saloon", icon: "saloon.svg" },
      { name: "Hatchback", icon: "hatchback.svg" },
      { name: "Estate", icon: "estate.svg" },
      { name: "MPV", icon: "MPV.svg" },
      { name: "SUV", icon: "SUV.svg" },
      { name: "Van", icon: "van.svg" },
      { name: "Pickup", icon: "pickup.svg" }
    ]
  end
end
