module Api
  class EmployeesController < BaseController
    def index
      authorize Employee
      employees = policy_scope(Employee).where(employer_id: params[:employer_id])
      render json: employees
    end

    def show
      employee = Employee.find_by(employer_id: params[:employer_id], id: params[:id])
      return render json: { error: "Employee not found" }, status: :not_found unless employee

      authorize employee
      render json: employee
    end

    def create
      employee = Employee.new(employee_params.merge(employer_id: params[:employer_id]))
      authorize employee

      if employee.save
        render json: employee, status: :created
      else
        render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      employee = Employee.find_by(employer_id: params[:employer_id], id: params[:id])
      return render json: { error: "Employee not found" }, status: :not_found unless employee

      authorize employee

      if employee.update(employee_params)
        render json: employee, status: :ok
      else
        render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      employee = Employee.find_by(employer_id: params[:employer_id], id: params[:id])
      return render json: { error: "Employee not found" }, status: :not_found unless employee

      authorize employee
      employee.destroy
      head :no_content
    end

    private

    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :email, :sex, :date_of_birth)
    end
  end
end
