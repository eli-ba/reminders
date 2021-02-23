require 'ffaker'

FactoryGirl.define do
  factory :reminder do
    content { FFaker::Lorem.word }
    time_margin { rand(60) }
  end
end
