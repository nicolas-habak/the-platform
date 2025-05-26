module Api
  class DivisionsController < BaseController

    def index
      authorize Division
      divisions = policy_scope(Division)
      render json: divisions
    end

    def show
      division = Division.find(params[:id])
      authorize division
      render json: division
    end

    def create
      authorize Division
      division = Division.new(division_params)

      if division.save
        render json: division, status: :created
      else
        render json: { errors: division.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      division = Division.find(params[:id])
      authorize division

      if division.update(division_params)
        render json: division, status: :ok
      else
        render json: { errors: division.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      division = Division.find(params[:id])
      authorize division
      division.destroy
      head :no_content
    end

    private

    def division_params
      params.require(:division).permit(:name, :code, :employer_id, :policy_id)
    end
  end
end
