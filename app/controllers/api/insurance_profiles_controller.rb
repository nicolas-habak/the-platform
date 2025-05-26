module Api
  class InsuranceProfilesController < BaseController
    def index
      authorize InsuranceProfile
      insurance_profiles = policy_scope(InsuranceProfile).where(employee_id: params[:employee_id])
      render json: insurance_profiles
    end

    def show
      insurance_profile = InsuranceProfile.find_by(employee_id: params[:employee_id], id: params[:id])
      return render json: { error: "Insurance Profile not found" }, status: :not_found unless insurance_profile

      authorize insurance_profile
      render json: insurance_profile
    end

    def create
      insurance_profile = InsuranceProfile.new(insurance_profile_params.merge(employee_id: params[:employee_id]))
      authorize insurance_profile

      if insurance_profile.save
        render json: insurance_profile, status: :created
      else
        render json: { errors: insurance_profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      insurance_profile = InsuranceProfile.find_by(employee_id: params[:employee_id], id: params[:id])
      return render json: { error: "Insurance Profile not found" }, status: :not_found unless insurance_profile

      authorize insurance_profile

      if insurance_profile.update(insurance_profile_params)
        render json: insurance_profile, status: :ok
      else
        render json: { errors: insurance_profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      insurance_profile = InsuranceProfile.find_by(employee_id: params[:employee_id], id: params[:id])
      return render json: { error: "Insurance Profile not found" }, status: :not_found unless insurance_profile

      authorize insurance_profile
      insurance_profile.destroy
      head :no_content
    end

    private

    def insurance_profile_params
      params.require(:insurance_profile).permit(:life, :smoker, :health, :dental, :start_date, :end_date, :division_id)
    end
  end
end
