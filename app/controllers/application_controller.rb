require 'http_status'
require 'error_msg'

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  before_filter :authenticate

  private

  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @access_token = token
      result = false
      @user = User.find_by access_token: @access_token
      if @user
        elapsed_hours = ((DateTime.current - @user.access_token_created_at.to_datetime) * 24).to_i
        # Access Token expires in 2 houres
        if elapsed_hours <= 2
          result = true
        end
      end
      result
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { errors: ErrorMsg.for(:bad_credentials) }, status: HttpStatus.for(:unauthorized)
  end
end
