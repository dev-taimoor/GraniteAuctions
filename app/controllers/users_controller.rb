class UsersController < ApplicationController
  before_action :ensure_admin
  skip_before_action :ensure_admin, only: %i[ verification user_verification ]

  def verification
    ActiveRecord::Base.transaction do
      if @current_user.update(user_params)
        @current_user.verification_image1.attach(params[:verification_image1]) if params[:verification_image1].present?
        @current_user.verification_image2.attach(params[:verification_image2]) if params[:verification_image2].present?
        @current_user.image.attach(params[:image]) if params[:image].present?
        if params[:user][:payment_status] == "true"
          redirect_to create_checkout_session_path
        else
          redirect_to car_collection_path, notice: 'Verification submitted successfully, Our team will review your account details shortly and you will be able to buy or bid on our platform. Thanks!'
        end
      else
        redirect_to user_verification_path, notice: 'An Error Occurred'
      end
    rescue ActiveRecord::StatementInvalid => e
      # Handle database lock exception
      redirect_to user_verification_path, notice: 'Database is busy, please try again later.'
    end
  end

  def index
    if params[:search].present?
      @users = User.where("full_name LIKE ?", "%#{params[:search]}%").paginate(page: params[:page], per_page: 10)
      @mobile_users = User.where("full_name LIKE ?", "%#{params[:search]}%").paginate(page: params[:mobile_page], per_page: 1)
    else
      @users = User.paginate(page: params[:page], per_page: 10)
      @mobile_users = User.paginate(page: params[:mobile_page], per_page: 1)
    end
  end

  def preview
    @user = User.find(params[:id])
    @user_stat_data = @user.get_revenue

    respond_to do |format|
      format.js
    end
  end

  def approve_user
    @user = User.find(params[:id])
    @user.update(admin_status: "approved")
    redirect_to users_path, notice: 'User Approved'
  end

  def reject_user
    @user = User.find(params[:id])
    @user.update(admin_status: "rejected")
    redirect_to users_path, notice: 'User Rejected'
  end

  def user_verification
  end

  private

  def user_params
    params.require(:user).permit(:business_name, :vat_number, :breakers_licensing, :role, :phone_number, :address_line_1, :address_line_2, :city, :state, :country, :postcode)
  end

  def ensure_admin
    authorize! :manage, User
  end
end
