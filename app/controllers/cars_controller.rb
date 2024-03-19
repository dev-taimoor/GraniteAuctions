class CarsController < ApplicationController

  def index
    @car = Car.new
    @cars = Car.all
  end

  def destroy
    begin
      @car = Car.find(params[:id])
      authorize! :destroy, @car

      if @car.destroy
        redirect_to cars_path, notice: 'Car was successfully destroyed.'
      else
        redirect_to cars_path, notice: 'Car was not created.'
      end
    rescue => e
      redirect_to cars_path, notice: "An error occurred: #{e.message}"
    end
  end

  def create
    begin
      @car = Car.new(car_params)
      authorize! :create, @car
      @car.image.attach(params[:image]) if params[:image].present?

      if @car.save
        redirect_to cars_path, notice: 'Car was successfully created.'
      else
        redirect_to cars_path, notice: 'Car was not created.'
      end
    rescue => e
      redirect_to cars_path, notice: "An error occurred: #{e.message}"
    end
  end

  def new
    @car = Car.new
  end

  def edit
    @car = Car.find(params[:id])
  end

  def update
    begin
      @car = Car.find(params[:id])
      authorize! :update, @car

      @car.image.attach(params[:image]) if params[:image].present?

      if @car.update(car_params)
        redirect_to cars_path, notice: 'Car was successfully updated.'
      else
        redirect_to cars_path, notice: 'Car was not updated.'
      end
    rescue => e
      redirect_to cars_path, notice: "An error occurred: #{e.message}"
    end
  end

  private

  def car_params
    params.require(:car).permit(:make_model, :reserve_auction_price, :buy_now_price, :description, :salvage_category_id, :category_id, :location, :delivery_cost, :image)
  end

end