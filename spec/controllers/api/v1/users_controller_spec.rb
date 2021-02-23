require 'spec_helper'
require 'error_msg'
require 'http_status'

def context_when_the_password_is_short(http_method:, action:)
  context 'when the password is short' do
    before(:each) do
      invalid_user_attributes = {
        :name => FFaker::Name.name,
        :email => FFaker::Internet.email,
        :password => '12', # wrong value!
        :location => FFaker::Address.country + ', ' + FFaker::Address.city
      }
      if http_method == :post and action == :update
        @user = FactoryGirl.create :user
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      end
      method(http_method).call(action, invalid_user_attributes, format: :json)
    end

    it 'renders an errors json' do
      user_response = json_response
      expect(user_response[:errors]).to eql(ErrorMsg.for(:password_too_short))
    end

    it { should respond_with HttpStatus.for(:invalid_arguments) }
  end
end

def context_when_the_email_is_less_than_3_characters(http_method:, action:)
  context 'when the email is less than 3 characters' do
    before(:each) do
      invalid_user_attributes = {
        :name => FFaker::Name.name,
        :email => 'a@', # wrong value!
        :password => '12345',
        :location => FFaker::Address.country + ', ' + FFaker::Address.city
      }
      if http_method == :post and action == :update
        @user = FactoryGirl.create :user
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      end
      method(http_method).call(action, invalid_user_attributes, format: :json)
    end

    it 'renders an errors json' do
      user_response = json_response
      expect(user_response[:errors][:email][0]).to include('is too short')
    end

    it { should respond_with HttpStatus.for(:invalid_arguments) }
  end
end

def context_when_the_email_format_is_invalid(http_method:, action:)
  context 'when the email format is invalid' do
    before(:each) do
      invalid_user_attributes = {
        :name => FFaker::Name.name,
        :email => 'invalid_email', # wrong value!
        :password => '12345',
        :location => FFaker::Address.country + ', ' + FFaker::Address.city
      }
      if http_method == :post and action == :update
        @user = FactoryGirl.create :user
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      end
      method(http_method).call(action, invalid_user_attributes, format: :json)
    end

    it 'renders an errors json' do
      user_response = json_response
      expect(user_response[:errors][:email][0]).to eql('is invalid')
    end

    it { should respond_with HttpStatus.for(:invalid_arguments) }
  end
end

def context_when_attributes_are_valid(http_method:, action:, status:)
  context 'when attributes are valid' do
    user_attributes = {
      :name => FFaker::Name.name,
      :email => FFaker::Internet.email,
      :password => '12345',
      :location => FFaker::Address.country + ', ' + FFaker::Address.city
    }

    before(:each) do
      if http_method == :post and action == :update
        @user = FactoryGirl.create :user
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
      end
      method(http_method).call(action, user_attributes, format: :json)
    end

    if http_method == :post and action == :create
      it 'renders the json representation for the user record just created' do
        user_response = json_response
        expect(user_response[:name]).to eql user_attributes[:name]
        expect(user_response[:email]).to eql user_attributes[:email]
        expect(user_response[:location]).to eql user_attributes[:location]
      end
    end

    it { should respond_with status }
  end
end

describe Api::V1::UsersController do
  describe 'GET #show' do
    context 'valid token' do
      before(:each) do
        @user = FactoryGirl.create :user
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        get :show, nil, format: :json
      end

      it 'returns the information about a user on a hash' do
        user_response = json_response
        expect(user_response[:name]).to eql @user.name
        expect(user_response[:email]).to eql @user.email
        expect(user_response[:location]).to eql @user.location
      end

      it { should respond_with HttpStatus.for(:success) }
    end

    context_when_invalid_token(http_method: :get, action: :show)
  end

  describe 'POST #create' do
    context_when_attributes_are_valid(http_method: :post, action: :create, status: HttpStatus.for(:entity_successfully_created))
    context_when_the_password_is_short(http_method: :post, action: :create)
    context_when_the_email_is_less_than_3_characters(http_method: :post, action: :create)
    context_when_the_email_format_is_invalid(http_method: :post, action: :create)

    context 'when missing attributes' do
      before(:each) do
        @invalid_user_attributes = {
          :name => FFaker::Name.name,
          :email => 'a@'
        }
        post :create, @invalid_user_attributes, format: :json
      end

      it 'renders an errors json' do
        user_response = json_response
        expect(user_response[:errors]).to eql(ErrorMsg.for(:invalid_arguments))
      end

      it { should respond_with HttpStatus.for(:invalid_arguments) }
    end
  end

  describe 'POST #update' do
    context_when_invalid_token(http_method: :post, action: :update)
    context_when_attributes_are_valid(http_method: :post, action: :update,
                                      status: HttpStatus.for(:entity_successfully_updated))
    context_when_the_password_is_short(http_method: :post, action: :update)
    context_when_the_email_is_less_than_3_characters(http_method: :post, action: :update)
    context_when_the_email_format_is_invalid(http_method: :post, action: :update)
  end

  describe 'DELETE #destroy' do
    context_when_invalid_token(http_method: :delete, action: :destroy)

    context 'when successfully deleted' do
      before(:each) do
        @user = FactoryGirl.create :user
        request.headers['Authorization'] = 'Token token="' + @user.access_token + '"'
        delete :destroy, nil, format: :json
      end

      it { should respond_with HttpStatus.for(:entity_successfully_updated) }
    end
  end
end
