module Api
  class BaseController < ActionController::API
    before_action :authenticate_user!

    attr_reader :current_user

    private

    def authenticate_user!
      header = request.headers['Authorization']
      token = header.to_s.split(' ').last
      @current_user = User.find_by(token: token)

      unless @current_user
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
