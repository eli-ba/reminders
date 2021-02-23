class HttpStatus
  def self.for(status_case)
    case status_case
    when :success
      200
    when :entity_successfully_created
      201
    when :entity_successfully_updated
      204
    when :entity_not_found
      404
    when :invalid_arguments
      422
    when :unauthorized
      401
    end
  end
end
