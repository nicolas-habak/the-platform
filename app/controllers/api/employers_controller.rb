module Api
  class EmployersController < BaseController

    def index
      authorize Employer
      policies = policy_scope(Employer)
      render json: policies
    end

    def show
      employer = Employer.find(params[:id])
      authorize employer
      render json: employer
    end

    def create
      authorize Employer
      employer = Employer.new(employer_params)

      if employer.save
        render json: employer, status: :created
      else
        render json: { errors: employer.errors }, status: :unprocessable_entity
      end
    end

    def update
      employer = Employer.find(params[:id])
      authorize employer

      if employer.update(employer_params)
        render json: employer, status: :ok
      else
        render json: { errors: employer.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      employer = Employer.find(params[:id])
      authorize employer
      employer.destroy
      head :no_content
    end

    private

    def employer_params
      params.require(:employer).permit(:name, :address)
    end
  end
end
