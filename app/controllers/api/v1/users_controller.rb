require 'password_encryption'
require 'http_status'

class Api::V1::UsersController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate, :only => [:create]

  PASSWORD_MIN_LENGTH = 5

  def show
    if @user
      respond_with @user
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  def create
    user = User.new
    user.name = params.require(:name)
    user.email = params.require(:email)
    password = params.require(:password)
    if password.length < PASSWORD_MIN_LENGTH
      render json: { errors: ErrorMsg.for(:password_too_short) }, status: HttpStatus.for(:invalid_arguments)
      return
    end
    user.encrypted_password = PasswordEncryption.encrypt(password)
    if params[:location]
      user.location = params[:location]
    end

    if user.save
      render json: user, status: HttpStatus.for(:entity_successfully_created)
    else
      render json: { errors: user.errors }, status: HttpStatus.for(:invalid_arguments)
    end
  rescue ActionController::ParameterMissing
    render json: { errors: ErrorMsg.for(:invalid_arguments) }, status: HttpStatus.for(:invalid_arguments)
  end

  def update
    if @user
      update_attrs = user_params.clone.except(:password)
      if user_params[:password] and user_params[:password].length < PASSWORD_MIN_LENGTH
        render json: { errors: ErrorMsg.for(:password_too_short) }, status: HttpStatus.for(:invalid_arguments)
        return
      else
        update_attrs[:encrypted_password] = PasswordEncryption.encrypt(user_params[:password])
      end
      if @user.update(update_attrs)
        head HttpStatus.for(:entity_successfully_updated)
      else
        render json: { errors: @user.errors }, status: HttpStatus.for(:invalid_arguments)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  def destroy
    if @user
      @user.destroy
      head HttpStatus.for(:entity_successfully_updated)
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  private

  def user_params
    params.permit(:name, :email, :location, :password, :status, :current_activity_id, :profile_picture_id)
  end
end
