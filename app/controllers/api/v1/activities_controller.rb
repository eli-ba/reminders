require 'error_msg'
require 'http_status'

class Api::V1::ActivitiesController < ApplicationController
  respond_to :json

  def show
    if @user
      activity_id = params[:id]
      if Activity.exists?(activity_id)
        activity = Activity.find(activity_id)
        if activity.user_id == @user.id
          respond_with activity
        else
          render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
        end
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  def all
    if @user
      render status: HttpStatus.for(:success), json: Activity.all.select(:id,
                                                                         :name,
                                                                         :start_time_hour,
                                                                         :start_time_min,
                                                                         :end_time_hour,
                                                                         :end_time_min,
                                                                         :start_date,
                                                                         :end_date,
                                                                         :is_repeating,
                                                                         :confirm_when_finished)
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  def create
    if @user
      @activity = @user.activities.create(activity_params)
      @activity.save!
      render json: @activity, status: HttpStatus.for(:entity_successfully_created)
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  rescue ActiveRecord::StatementInvalid
    render json: { errors: ErrorMsg.for(:invalid_arguments) }, status: HttpStatus.for(:invalid_arguments)
  end

  def update
    if @user
      activity_id = params[:id]
      if Activity.exists?(activity_id)
        activity = Activity.find(activity_id)
        if activity.user_id == @user.id
          activity.update!(activity_params)
          head HttpStatus.for(:entity_successfully_updated)
        else
          render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
        end
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  rescue
    render json: { errors: ErrorMsg.for(:invalid_arguments) }, status: HttpStatus.for(:invalid_arguments)
  end

  def destroy
    if @user
      activity_id = params[:id]
      if Activity.exists?(activity_id)
        activity = Activity.find(activity_id)
        if activity.user_id == @user.id
          activity.destroy
          head 204
        else
          render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
        end
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  private

  def activity_params
    params.permit(:name,
                  :start_time_hour,
                  :start_time_min,
                  :end_time_hour,
                  :end_time_min,
                  :start_date,
                  :end_date,
                  :is_repeating,
                  :confirm_when_finished)
  end
end
