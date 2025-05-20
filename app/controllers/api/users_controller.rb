module Api
  class UsersController < BaseController
    def index
      users = User.order(:id)
      render json: users
    end
  end
end