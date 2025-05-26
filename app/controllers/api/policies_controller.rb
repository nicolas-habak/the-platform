module Api
  class PoliciesController < BaseController
    def index
      authorize Policy
      policies = policy_scope(Policy).where(employer_id: params[:employer_id])
      render json: policies
    end

    def show
      policy = Policy.find_by(employer_id: params[:employer_id], id: params[:id])
      return render json: { error: "Policy not found" }, status: :not_found unless policy

      authorize policy
      render json: policy
    end

    def create
      policy = Policy.new(policy_params.merge(employer_id: params[:employer_id]))
      authorize policy

      if policy.save
        render json: policy, status: :created
      else
        render json: { errors: policy.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      policy = Policy.find_by(employer_id: params[:employer_id], id: params[:id])
      return render json: { error: "Policy not found" }, status: :not_found unless policy

      authorize policy

      if policy.update(policy_params)
        render json: policy, status: :ok
      else
        render json: { errors: policy.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      policy = Policy.find_by(employer_id: params[:employer_id], id: params[:id])
      return render json: { error: "Policy not found" }, status: :not_found unless policy

      authorize policy
      policy.destroy
      head :no_content
    end

    private

    def policy_params
      params.require(:policy).permit(:number, :life, :health_single, :health_family, :dental_single, :dental_family, :start_date, :end_date, :provider_id)
    end
  end
end
