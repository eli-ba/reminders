require 'http_status'
require 'error_msg'

class Api::V1::RemindersController < ApplicationController
  respond_to :json

  def create
    if @user
      activity = find_activity
      if activity
        @reminder = activity.reminders.create(reminder_params)
        @reminder.save!
        render json: @reminder, status: HttpStatus.for(:entity_successfully_created)
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  rescue ActiveRecord::StatementInvalid
    render json: { errors: ErrorMsg.for(:invalid_arguments) }, status: HttpStatus.for(:invalid_arguments)
  end

  def show
    if @user
      activity = find_activity
      if activity
        reminder = Reminder.find_by id: params[:id], activity_id: activity.id
        if reminder
          respond_with reminder
        else
          render json: { errors: ErrorMsg.for(:reminder_not_found) }, status: HttpStatus.for(:entity_not_found)
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
      activity = find_activity
      if activity
        respond_with activity.reminders
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  def update
    if @user
      activity = find_activity
      if activity
        reminder = Reminder.find_by id: params[:id], activity_id: params[:activity_id]
        if reminder
          reminder.update!(reminder_params)
          head HttpStatus.for(:entity_successfully_updated)
        else
          render json: { errors: ErrorMsg.for(:reminder_not_found) }, status: HttpStatus.for(:entity_not_found)
        end
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  rescue
    render json: { errors: ErrorMsg.for(:invalid_attributes) }, status: HttpStatus.for(:invalid_arguments)
  end

  def destroy
    if @user
      activity = find_activity
      if activity
        reminder = Reminder.find_by id: params[:id], activity_id: params[:activity_id]
        if reminder
          reminder.destroy
          head HttpStatus.for(:entity_successfully_updated)
        else
          render json: { errors: ErrorMsg.for(:reminder_not_found) }, status: HttpStatus.for(:entity_not_found)
        end
      else
        render json: { errors: ErrorMsg.for(:activity_not_found) }, status: HttpStatus.for(:entity_not_found)
      end
    else
      render json: { errors: ErrorMsg.for(:user_not_found) }, status: HttpStatus.for(:entity_not_found)
    end
  end

  private

  def reminder_params
    params.permit(:content, :time_margin)
  end

  def find_activity
    activity = Activity.find_by user_id: @user.id, id: params[:activity_id]
    if !activity or activity.user_id != @user.id
      activity = nil
    end
    activity
  end
end
