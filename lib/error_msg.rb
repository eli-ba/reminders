class ErrorMsg
  def self.for(error_desc)
    case error_desc
    when :user_not_found
      'User not found'
    when :unauthorized_access
      'Unauthorized Access'
    when :invalid_attributes
      'Invalid attributes'
    when :password_too_short
      'Password too short'
    when :bad_credentials
      'Bad credentials'
    when :invalid_arguments
      'Invalid arguments'
    when :activity_not_found
      'Activity not found'
    when :reminder_not_found
      'Reminder not found'
    end
  end
end
