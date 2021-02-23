class User < ActiveRecord::Base
  has_many :activities, dependent: :destroy
  validates :name, :presence => true
  validates :email, :presence => true, uniqueness: true, length: { minimum: 3 }
  validates_format_of :email, :with => /@/
  validates :encrypted_password, :presence => true

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
      self.access_token_created_at = DateTime.current
    end while self.class.exists?(access_token: access_token)
  end

  # Exclude confidential attributes from json output.
  def to_json(options = {})
    options[:except] ||= [:encrypted_password, :access_token, :access_token_created_at, :created_at, :updated_at]
    super(options)
  end
end
