class CarsController < ApplicationController
  include CarPaymentConcern

  before_action :ensure_admin, except: %i[buy bid car_purchase]
  before_action :verify_user_status, only: %i[buy bid]

  def index
    @car = Car.new
    if params[:search].present?
      @cars = Car.where("make LIKE ? OR model LIKE ?", "%#{params[:search]}%").paginate(page: params[:page], per_page: 10)
    else
      @cars = Car.paginate(page: params[:page], per_page: 10)
    end
    render :index
  end

  def destroy
    begin
      @car = Car.find(params[:id])

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

  def show
    @car = Car.find(params[:id])
  end

  def update
    begin
      @car = Car.find(params[:id])
      
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

  def add_to_auction
    @car = Car.find(params[:id])
    @auction = Auction.find(params[:auction_id])
    return unless @car || @auction
    authorize! :create, @auction
    unless @auction.auction_cars.exists?(auction: @auction, car: @car)
      AuctionCar.create(auction: @auction, car: @car)
    end
  end

  def buy
    car = Car.find(params[:car_id])
    session = payment_session(car)
    redirect_to session.url, allow_other_host: true
  end

  def bid

  end

  def car_purchase
    if params[:success] == 'true' && handle_transaction_success
      redirect_to car_collection_path , notice: "Payment successful"
    else
      redirect_to car_collection_path, notice: 'Payment failed, please try again'
    end
  end

  private

  def car_params
    params.require(:car).permit(:make_model, :year, :engine_capacity, :kms_driven, :reserve_auction_price, :buy_now_price, :description, :salvage_category_id, :category_id, :location, :delivery_cost, :image, :make, :model)
  end

  def ensure_admin
    authorize! :manage, Car
  end

  def verify_user_status
    if !current_user.verification_completed?
      redirect_to user_verification_path, notice: 'User verification is pending'
    elsif current_user.admin_status == 'pending'
      redirect_to car_collection_path, notice: 'User needs to be verified from admin.'
    end
  end
end
