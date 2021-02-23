require 'password_encryption'

class Api::V1::TokensController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate, :only => [:create]

  ERR_CREATE_SESSION = 'Email or password incorrect'
  ERR_UNAUTHORIZED_ACCESS = 'Unauthorized Access'

  def create
    user = User.find_by email: params[:email]
    if user
      if PasswordEncryption.check? params[:password], user.encrypted_password
        user.generate_access_token
        user.save
        render json: { access_token: user.access_token }, status: 200
      else
        render json: { errors: ERR_CREATE_SESSION }, status: 401
      end
    else
      render json: { errors: ERR_CREATE_SESSION }, status: 401
    end
  end

  private

  def session_params
    params.permit(:email, :password)
  end
end
