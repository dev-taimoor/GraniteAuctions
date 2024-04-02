class UsersController < ApplicationController

  def verification
    if @current_user.dealer?
      @current_user.update(user_params)
    end
    # Remove redundant update here
    # Ensure that @current_user is updated only if it's not a dealer
    unless @current_user.dealer?
      @current_user.update(user_params)
    end

    # Attach verification images if present in params
    @current_user.verification_image1.attach(params[:verification_image1]) if params[:verification_image1].present?
    @current_user.verification_image2.attach(params[:verification_image2]) if params[:verification_image2].present?
    
    redirect_to user_dashboard_path, notice: 'Verification successful'
  end

  def user_verification
  end

  private

  def user_params
    params.require(:user).permit(:business_name, :vat_number, :breakers_licensing, :role)
  end
end
