class UsersController < ApplicationController
  before_action :ensure_admin
  skip_before_action :ensure_admin, only: %i[ verification user_verification ]

  def verification
    if @current_user.update(user_params)
      @current_user.verification_image1.attach(params[:verification_image1]) if params[:verification_image1].present?
      @current_user.verification_image2.attach(params[:verification_image2]) if params[:verification_image2].present?
      @current_user.image.attach(params[:image]) if params[:image].present?
      if params[:user][:payment_status]
        redirect_to create_checkout_session_path
      else
        redirect_to car_collection_path, notice: 'Verification successful'
      end
    else
      redirect_to user_verification_path, notice: 'An Error Occured'
    end
  end

  def verification
    ActiveRecord::Base.transaction do
      if @current_user.update(user_params)
        @current_user.verification_image1.attach(params[:verification_image1]) if params[:verification_image1].present?
        @current_user.verification_image2.attach(params[:verification_image2]) if params[:verification_image2].present?
        @current_user.image.attach(params[:image]) if params[:image].present?
        if params[:user][:payment_status]
          redirect_to create_checkout_session_path
        else
          redirect_to car_collection_path, notice: 'Verification successful'
        end
      else
        redirect_to user_verification_path, notice: 'An Error Occurred'
      end
    end
  rescue ActiveRecord::StatementInvalid => e
    # Handle database lock exception
    redirect_to user_verification_path, notice: 'Database is busy, please try again later.'
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
    params.require(:user).permit(:business_name, :vat_number, :breakers_licensing, :role, :phone_number, :address)
  end

  def ensure_admin
    authorize! :manage, User
  end
end
