require 'http_status'

module SharedMethods
  def context_when_invalid_token(http_method:, action:, params: nil)
    context 'invalid token' do
      before(:each) do
        request.headers['Authorization'] = 'Token token="wrongtoken"'
        method(http_method).call(action, params, format: :json)
      end

      it 'returns an errors json' do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it { should respond_with HttpStatus.for(:unauthorized) }
    end
  end
end
