require 'ffaker'

FactoryGirl.define do
  factory :activity do
    name { FFaker::Lorem.word }
    user { create(:user) }
    start_time_hour { 10 }
    start_time_min { 15 }
    end_time_hour { 12 }
    end_time_min { 15 }
    start_date { '2015-06-01' }
    end_date { '2015-06-05' }
    is_repeating { FFaker::Boolean.maybe }
    confirm_when_finished { FFaker::Boolean.maybe }

    after(:create) do |activity|
      activity.reminders << create_list(:reminder, 5, activity: activity)
    end
  end
end
