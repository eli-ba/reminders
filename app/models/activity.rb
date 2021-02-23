class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :reminders, dependent: :destroy

  # Exclude confidential attributes from json output.
  def to_json(options = {})
    options[:except] ||= [:created_at, :updated_at]
    super(options)
  end
end
