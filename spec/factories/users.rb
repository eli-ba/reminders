require 'ffaker'
require 'password_encryption'

FactoryGirl.define do
  factory :user do
    name { FFaker::NameDE.name }
    email { FFaker::Internet.email }
    encrypted_password PasswordEncryption.encrypt('12345')
    access_token 'abcdxyz'
    access_token_created_at DateTime.current

    factory :user_with_activities do
      after(:create) do |user|
        user.activities << create_list(:activity, 5, user: user)
      end
    end
  end
end
