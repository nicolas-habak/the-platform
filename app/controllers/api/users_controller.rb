module Api
  class UsersController < BaseController
    def index
      authorize User, :index?
      users = policy_scope(User)
      render json: users
    end

    def show
      user = User.find(params[:id])
      authorize user, :show?
      render json: user
    end

    def update
      user = User.find(params[:id])
      authorize user, :update?

      if user.update(user_params(user))
        render json: user, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create
      authorize User, :create?
      user = User.new(user_params(User))
      if user.save
        render json: user, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params(user)
      params.require(:user).permit(policy(user).permitted_attributes)
    end
  end
end
