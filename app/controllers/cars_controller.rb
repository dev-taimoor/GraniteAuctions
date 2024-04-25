class CarsController < ApplicationController
  include CarPaymentConcern
  before_action :ensure_admin, except: %i[buy highest_bid car_purchase submit_bid successful_bid]
  before_action :verify_user_status, only: %i[buy car_purchase]
  before_action :set_car, only: %i[edit update destroy show add_to_auction highest_bid submit_bid buy]

  def index
    @car = Car.new
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @cars = Car.where("make LIKE ? OR model LIKE ?", search_term, search_term).paginate(page: params[:page], per_page: 10)
      else
      @cars = Car.paginate(page: params[:page], per_page: 10)
    end
    render :index
  end

  def destroy
    begin
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
  end

  def show
  end

  def update
    begin
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

  # need to discuss this further
  def add_to_auction
    begin
      @auction = Auction.find(params[:auction_id])
      return unless @car || @auction
      authorize! :create, @auction
      unless @auction.auction_cars.exists?(auction: @auction, car: @car)
        AuctionCar.create!(auction: @auction, car: @car)
      end
      flash[:success] = "Car successfully added to auction."
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
    end
    
  end

  def buy
    redirect_to payment_session.url, allow_other_host: true
  end

  def highest_bid
    verification_error = verify_user_status(true)
    render json: verification_error.present? ? verification_error : { highest_bid_amount: @car.highest_bid_amount }
  end

  def submit_bid
    auction = @car.auctions.current.first
    bid = Bid.find_or_initialize_by(car_id: @car.id, auction_id: auction.id, user_id: current_user.id)
    create_hold_amount = bid.id.blank? # only create hold amount for new bids
    bid.update(amount: params[:bid_amount])
    if create_hold_amount
      # handles the use case if we are already have the payment method Id of current user
      # directly holding the security amount against the bidding
      if current_user.payment_method_id.present?
        hold_bidding_security(current_user.payment_method_id, bid.id)
        redirect_to car_collection_path, notice: "Bid successful"
      else
        # in case of payment method not present, create a session for getting payment method
        # upon sucess, hold the security amount
        session = bidding_payment_session(bid)
        redirect_to session.url , allow_other_host: true
      end
    else
      redirect_back fallback_location: car_collection_path, notice: "Bid successful"
    end
  end

  def successful_bid
    session = fetch_session_data(params[:session_id])
    payment_method = session.setup_intent.payment_method
    current_user.update(payment_method_id: payment_method)
    hold_bidding_security(payment_method, session.metadata.bid_id)
    redirect_to car_collection_path, notice: "Bid successful"
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

  def verify_user_status(json_response = false)
    if !current_user.verification_completed?
      if json_response
        flash[:error] = 'User verification is pending'
        return { error: 'User verification is pending'}
      end
      # return { error: 'User verification is pending'} if json_response
      redirect_to user_verification_path, notice: 'User verification is pending'
    elsif current_user.admin_status == 'pending'
      if json_response
        flash[:error] = 'User needs to be verified from admin.'
        return { error: 'User needs to be verified from admin.'}
      end
      redirect_to car_collection_path, notice: 'User needs to be verified from admin.'
    end
  end

  def set_car
    @car = Car.find(params[:id] || params[:car_id])
  end
end
