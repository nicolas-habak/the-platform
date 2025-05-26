module Api
  class DependantsController < BaseController

    def index
      authorize Dependant
      dependants = policy_scope(Dependant)
      render json: dependants
    end

    def show
      dependant = Dependant.find(params[:id])
      authorize dependant
      render json: dependant
    end

    def create
      authorize Dependant
      dependant = Dependant.new(create_dependant_params)

      if dependant.save
        render json: dependant, status: :created
      else
        render json: { errors: dependant.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      dependant = Dependant.find(params[:id])
      authorize dependant

      if dependant.update(dependant_params)
        render json: dependant, status: :ok
      else
        render json: { errors: dependant.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      dependant = Dependant.find(params[:id])
      return render json: { error: "Dependant not found" }, status: :not_found if dependant.nil?

      authorize dependant
      dependant.destroy
      head :no_content
    end

    private

    def create_dependant_params
      params.require(:dependant).permit(:insurance_profile_id, :name, :date_of_birth, :relation, :has_disability)
    end

    def dependant_params
      params.require(:dependant).permit(:name, :date_of_birth, :relation, :has_disability)
    end
  end
end
