require 'spec_helper'
require 'http_status'
require 'error_msg'

describe Api::V1::RemindersController do
  describe 'GET #show' do
    context 'everything is valid' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        @reminder = @activity.reminders.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        get :show, id: @reminder.id, activity_id: @activity.id, format: :json
      end

      it 'returns information about a reminder on a hash' do
        reminder_response = json_response
        expect(reminder_response[:content]).to eql(@reminder.content)
        expect(reminder_response[:time_margin]).to eql(@reminder.time_margin)
      end

      it { should respond_with HttpStatus.for(:success) }
    end

    context_when_invalid_token(http_method: :get, action: :show, params: {id: -1, activity_id: -1})

    context 'activity owned by another user' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @another_user = FactoryGirl.create(:user_with_activities)
        @wrong_activity = @another_user.activities.first
        @reminder = @wrong_activity.reminders.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        get :show, id: @reminder.id, activity_id: @wrong_activity.id, format: :json
      end

      it 'returns errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end

    context 'reminder owned by another activity' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @first_activity = @user.activities.first
        @last_activity = @user.activities.last
        @last_reminder= @last_activity.reminders.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        get :show, id: @last_reminder.id, activity_id: @first_activity.id, format: :json
      end

      it 'return errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:reminder_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end
  end

  describe 'POST #create' do
    context_when_invalid_token(http_method: :get, action: :show, params: {id: -1, activity_id: -1})

    context 'when attributes are valid' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        @reminder_attributes = FactoryGirl.attributes_for(:reminder)
        @reminder_attributes[:activity_id] = @activity.id
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        post :create, @reminder_attributes, format: :json
      end

      it 'return the representation of the reminder just created' do
        expect(json_response[:content]).to eql(@reminder_attributes[:content])
        expect(json_response[:time_margin]).to eql(@reminder_attributes[:time_margin])
        expect(json_response[:activity_id]).to eql(@activity.id)
      end

      it { should respond_with HttpStatus.for(:entity_successfully_created) }
    end

    context 'activity owned by another user' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @another_user = FactoryGirl.create(:user_with_activities)
        @wrong_activity = @another_user.activities.first
        @reminder_attributes = FactoryGirl.attributes_for(:reminder)
        @reminder_attributes[:activity_id] = @wrong_activity.id
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        post :create, @reminder_attributes, format: :json
      end

      it 'returns errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end
  end

  describe 'PUT/PATCH #update' do
    context_when_invalid_token(http_method: :get, action: :show, params: {id: -1, activity_id: -1})

    context 'when attributes are valid' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        @reminder = @activity.reminders.first
        @update_attributes = FactoryGirl.attributes_for(:reminder)
        @update_attributes[:id] = @reminder.id
        @update_attributes[:activity_id] = @activity.id
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        patch :update, @update_attributes, format: :json
      end

      it { should respond_with HttpStatus.for(:entity_successfully_updated) }
    end

    context 'activity owned by another user' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @another_user = FactoryGirl.create(:user_with_activities)
        @wrong_activity = @another_user.activities.first
        @reminder = @wrong_activity.reminders.first
        @update_attributes = FactoryGirl.attributes_for(:reminder)
        @update_attributes[:id] = @reminder.id
        @update_attributes[:activity_id] = @wrong_activity.id
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        patch :update, @update_attributes, id: @reminder.id, format: :json
      end

      it 'returns errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end

    context 'reminder owned by another activity' do
      before(:each) do
        # Correct
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        @reminder = @activity.reminders.first

        # Wrong
        @another_user = FactoryGirl.create(:user_with_activities)
        @wrong_activity = @another_user.activities.first
        @wrong_reminder = @wrong_activity.reminders.first

        @update_attributes = FactoryGirl.attributes_for(:reminder)
        @update_attributes[:id] = @wrong_reminder.id
        @update_attributes[:activity_id] = @activity.id
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        patch :update, @update_attributes, id: @reminder.id, format: :json
      end

      it 'returns errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:reminder_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end
  end

  describe 'DELETE #destroy' do
    context_when_invalid_token(http_method: :get, action: :show, params: {id: -1, activity_id: -1})

    context 'when it is successfully destroyed' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        @reminder = @activity.reminders.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        delete :destroy, id: @reminder.id, activity_id: @activity.id, format: :json
      end

      it { should respond_with HttpStatus.for(:entity_successfully_updated) }
    end

    context 'activity owned by another user' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @another_user = FactoryGirl.create(:user_with_activities)
        @wrong_activity = @another_user.activities.first
        @reminder = @wrong_activity.reminders.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        delete :destroy, id: @reminder.id, activity_id: @wrong_activity.id, format: :json
      end

      it 'return errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end

    context 'reminder owned by another activity' do
      before(:each) do
        # Correct
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        @reminder = @activity.reminders.first
        # Wrong
        @another_user = FactoryGirl.create(:user_with_activities)
        @wrong_activity = @another_user.activities.first
        @wrong_reminder = @wrong_activity.reminders.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        delete :destroy, id: @wrong_reminder.id, activity_id: @activity.id, format: :json
      end

      it 'return errors json' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:reminder_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end
  end
end
