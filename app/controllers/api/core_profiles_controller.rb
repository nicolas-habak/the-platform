module Api
  class CoreProfilesController < BaseController
    def index
      authorize CoreProfile
      core_profiles = policy_scope(CoreProfile).where(employee_id: params[:employee_id])
      render json: core_profiles
    end

    def show
      core_profile = CoreProfile.find_by(employee_id: params[:employee_id], id: params[:id])
      return render json: { error: "Core Profile not found" }, status: :not_found unless core_profile

      authorize core_profile
      render json: core_profile
    end

    def create
      core_profile = CoreProfile.new(core_profile_params.merge(employee_id: params[:employee_id]))
      authorize core_profile

      if core_profile.save
        render json: core_profile, status: :created
      else
        render json: { errors: core_profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      core_profile = CoreProfile.find_by(employee_id: params[:employee_id], id: params[:id])
      return render json: { error: "Core Profile not found" }, status: :not_found unless core_profile

      authorize core_profile

      if core_profile.update(core_profile_params)
        render json: core_profile, status: :ok
      else
        render json: { errors: core_profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      core_profile = CoreProfile.find_by(employee_id: params[:employee_id], id: params[:id])
      return render json: { error: "Core Profile not found" }, status: :not_found unless core_profile

      authorize core_profile
      core_profile.destroy
      head :no_content
    end

    private

    def core_profile_params
      params.require(:core_profile).permit(:address, :salary, :start_date, :end_date, :hours_per_week)
    end
  end
end
