class AuctionsController < ApplicationController
  before_action :set_auction, only: %i[ show edit update destroy ]
  before_action :ensure_admin

  def index
    @auctions = Auction.current.or(Auction.pending)
    @live_auctions = Auction.current.includes(:auction_cars)
    @auction_cars = @live_auctions.map(&:auction_cars).flatten
    @auction_cars_paginated = Kaminari.paginate_array(@auction_cars).page(params[:live_auction_page]).per(5)
    @cars = Car.available.paginate(page: params[:page], per_page: 5)
    @cars_paginated = Car.available.paginate(page: params[:mcars_page], per_page: 1)
    @sold_cars = Car.sold_cars.paginate(page: params[:sold_page], per_page: 2)
  end
  
  def create
    @auction = Auction.new(auction_params)

    respond_to do |format|
      if @auction.save
        format.html { redirect_to auctions_path, notice: "Auction was successfully created." }
        format.json { render :show, status: :created, location: @auction }
      else
        format.html { redirect_to auctions_path, notice: "Auction was NOT created." }
      end
    end
  end

  def all_auctions
    if params[:search].present?
      @auctions = Auction.where("title LIKE ?", "%#{params[:search]}%").paginate(page: params[:page], per_page: 10)
    else
      @auctions = Auction.paginate(page: params[:page], per_page: 10)
    end
  end

  def cars
    @auction = Auction.find(params[:id])
    @cars = @auction.cars
    render partial: 'cars_list', locals: { cars: @cars }
  end

  def delete_auction_car
    @auction = Auction.find(params[:id])
    @car = @auction.cars.find(params[:car_id])
    if @auction.remove_car(@car)
      render json: { success: true, message: 'Car successfully removed from auction.' }
    else
      render json: { success: false, message: 'Failed to remove car from auction.' }, status: :unprocessable_entity
    end
  end

  # GET /auctions/1 or /auctions/1.json
  def show
  end

  # GET /auctions/new
  def new
    @auction = Auction.new
  end

  # GET /auctions/1/edit
  def edit
  end

  

  # PATCH/PUT /auctions/1 or /auctions/1.json
  def update
    respond_to do |format|
      if @auction.update(auction_params)
        format.html { redirect_to auction_url(@auction), notice: "Auction was successfully updated." }
        format.json { render :show, status: :ok, location: @auction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auctions/1 or /auctions/1.json
  def destroy
    @auction.destroy

    respond_to do |format|
      format.html { redirect_to auctions_url, notice: "Auction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_auction
      @auction = Auction.find(params[:id])
    end

    def auction_params
      params.require(:auction).permit(:title, :lot_no, :start_time, :end_time)
    end

    def ensure_admin
      authorize! :manage, Auction
    end
end
