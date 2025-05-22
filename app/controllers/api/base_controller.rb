module Api
  class BaseController < ActionController::API
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    before_action :authenticate_user!

    attr_reader :current_user

    private

    def authenticate_user!
      header = request.headers["Authorization"]
      token = header.to_s.split(" ").last
      @current_user = User.find_by(token: token)

      unless @current_user
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def user_not_authorized
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
