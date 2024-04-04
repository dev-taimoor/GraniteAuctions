class Users::RegistrationsController < Devise::RegistrationsController
  # Custom logic for user registrations
  before_action :redirect_signed_in_user, only: [:new]
  before_action :configure_sign_up_params, only: [:create]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name, :user_name])
  end

  def after_sign_up_path_for(resource)
    user_verification_path
  end

  private

  def redirect_signed_in_user
    if user_signed_in?
      redirect_to root_path, flash: "You are already signed in."
    end
  end
end

  