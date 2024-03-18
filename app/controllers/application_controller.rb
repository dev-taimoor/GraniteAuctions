class ApplicationController < ActionController::Base
  before_action :authenticate_user! # Ensure user is authenticated for every action
  before_action :set_current_user # Set current user

  private

  def set_current_user
    @current_user = current_user
  end
end
