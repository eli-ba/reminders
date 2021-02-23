require 'spec_helper'

describe Activity do
  before do
    @activity = FactoryGirl.create(:activity)
  end

  subject { @activity }

  it { should respond_to(:name) }
  it { should respond_to(:start_time_hour) }
  it { should respond_to(:start_time_min) }
  it { should respond_to(:end_time_hour) }
  it { should respond_to(:end_time_min) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:is_repeating) }
  it { should respond_to(:confirm_when_finished) }
  it { should respond_to(:user) }

  it { should be_valid }
end
