require 'spec_helper'
require 'http_status'
require 'error_msg'

def context_activity_doesnt_not_exist(http_method:, action:)
  context 'activity does not exist' do
    before(:each) do
      @user = FactoryGirl.create(:user_with_activities)
      request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      method(http_method).call(action, id: -1, format: :json)
    end

    it 'returns the json errors' do
      activity_response = json_response
      expect(activity_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
    end

    it { should respond_with HttpStatus.for(:entity_not_found) }
  end
end

def context_activity_owned_by_another_user(http_method:, action:)
  context 'activity owned by another user' do
    before(:each) do
      @user = FactoryGirl.create(:user_with_activities)
      @another_user = FactoryGirl.create(:user_with_activities)
      @activity = @another_user.activities.first
      request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      method(http_method).call(action, id: @activity.id, format: :json)
    end

    it 'returns the json errors' do
      activity_response = json_response
      expect(activity_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
    end

    it { should respond_with HttpStatus.for(:entity_not_found) }
  end
end

def context_context_when_attributes_are_valid(http_method:, action:, status:)
  context 'when attributes are valid' do
    before(:each) do
      @user = FactoryGirl.create(:user_with_activities)
      @activity_attributes = FactoryGirl.attributes_for(:activity)
      request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      if http_method == :patch and action == :update
        @activity = @user.activities.first
        @activity_attributes[:id] = @activity.id
      end
      method(http_method).call(action, @activity_attributes, format: :json)
    end

    if http_method == :post and action == :create
      it 'return the representation of the activity just created' do
        activity_response = json_response
        expect(activity_response[:name]).to eql(@activity_attributes[:name])
        expect(activity_response[:start_time_hour]).to eql(@activity_attributes[:start_time_hour])
        expect(activity_response[:start_time_min]).to eql(@activity_attributes[:start_time_min])
        expect(activity_response[:end_time_hour]).to eql(@activity_attributes[:end_time_hour])
        expect(activity_response[:end_time_min]).to eql(@activity_attributes[:end_time_min])
        expect(activity_response[:start_date]).to eql(@activity_attributes[:start_date])
        expect(activity_response[:end_date]).to eql(@activity_attributes[:end_date])
        expect(activity_response[:is_repeating]).to eql(@activity_attributes[:is_repeating])
        expect(activity_response[:confirm_when_finished]).to eql(@activity_attributes[:confirm_when_finished])
        expect(activity_response[:user_id]).to eql(@user.id)
      end
    end

    it { should respond_with status }
  end
end

describe Api::V1::ActivitiesController do
  describe 'GET #show' do
    context 'valid token and activity id' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        get :show, id: @activity.id, format: :json
      end

      it 'returns information about an activity on a hash' do
        activity_response = json_response
        expect(activity_response[:name]).to eql @activity.name
      end

      it { should respond_with HttpStatus.for(:success) }
    end

    context_when_invalid_token(http_method: :get, action: :show, params: {id: -1})
    context_activity_doesnt_not_exist(http_method: :get, action: :show)
    context_activity_owned_by_another_user(http_method: :get, action: :show)
  end

  describe 'POST #create' do
    context_when_invalid_token(http_method: :post, action: :create, params: {id: -1})
    context_context_when_attributes_are_valid(http_method: :post, action: :create,
                                              status: HttpStatus.for(:entity_successfully_created))
  end

  describe 'PUT/PATCH #update' do
    context_when_invalid_token(http_method: :patch, action: :update, params: {id: -1})
    context_context_when_attributes_are_valid(http_method: :patch, action: :update,
                                              status: HttpStatus.for(:entity_successfully_updated))

    context 'activity owned by another user' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @another_user = FactoryGirl.create(:user_with_activities)
        @activity = @another_user.activities.first
        @update_attributes = FactoryGirl.attributes_for(:activity)
        @update_attributes[:id] = @activity.id
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        patch :update, @update_attributes, format: :json
      end

      it 'returns the json errors' do
        activity_response = json_response
        expect(activity_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end
  end

  describe 'DELETE #destroy' do
    context 'when it is successfully destroyed' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @activity = @user.activities.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        delete :destroy, id: @activity.id, format: :json
      end

      it { should respond_with HttpStatus.for(:entity_successfully_updated) }
    end

    context 'when the activity is owned by another user' do
      before(:each) do
        @user = FactoryGirl.create(:user_with_activities)
        @another_user = FactoryGirl.create(:user_with_activities)
        @activity = @another_user.activities.first
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        delete :destroy, id: @activity.id, format: :json
      end

      it 'returns the json errors' do
        expect(json_response[:errors]).to eql(ErrorMsg.for(:activity_not_found))
      end

      it { should respond_with HttpStatus.for(:entity_not_found) }
    end
  end
end
