class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  def index
  end

  def car_collection
    @vehicle_types = [
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
    per_page_items = request.user_agent =~ /Mobile|webOS/ ? 4 : 8
    @cars = Car.paginate(page: params[:page], per_page: per_page_items)
  end
end
