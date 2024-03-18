class Users::SessionsController < Devise::SessionsController
  # Custom logic for user sessions
  def after_sign_in_path_for(resource)
    if resource.verification_completed?
      dashboard_path
    else
      user_verification_path
    end
  end
end

