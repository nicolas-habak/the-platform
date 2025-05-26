require "rails_helper"

RSpec.describe "Employees API", type: :request do
  include_context "with authenticated users"

  let!(:employer) { create(:employer) }
  let!(:employees) { create_list(:employee, 3, employer: employer) }
  let!(:employee) { employees.first }

  let(:valid_params) do
    {
      employee: {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        sex: Faker::Gender.binary_type == 'Male' ? 'm' : 'f',
        date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65)
      }
    }
  end

  describe "GET employees" do
    context "when authenticated as admin" do
      it "returns all employees" do
        get api_employer_employees_path(employer), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(employees.count)
      end
    end

    context "when authenticated as actuary" do
      it "returns all employees" do
        get api_employer_employees_path(employer), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(employees.count)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employees_path(employer) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "GET employees/:id" do
    context "when admin views an employee" do
      it "returns the employee" do
        get api_employer_employee_path(employer, employee), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include("id" => employee.id, "first_name" => employee.first_name)
      end
    end

    context "when actuary views an employee" do
      it "returns the employee" do
        get api_employer_employee_path(employer, employee), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include("id" => employee.id, "first_name" => employee.first_name)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_path(employer, employee) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST employees" do
    context "when admin creates an employee" do
      it "successfully creates an employee" do
        expect {
          post api_employer_employees_path(employer), params: valid_params, headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Employee.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when actuary creates an employee" do
      it "successfully creates an employee" do
        expect {
          post api_employer_employees_path(employer), params: valid_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { Employee.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthorized" do
      before { post api_employer_employees_path(employer), params: valid_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "PATCH employees/:id" do
    let(:update_params) { { employee: { first_name: "Updated Name" } } }

    context "when admin updates an employee" do
      it "successfully updates the employee" do
        patch api_employer_employee_path(employer, employee), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(employee.reload.first_name).to eq("Updated Name")
      end
    end

    context "when actuary updates an employee" do
      it "successfully updates the employee" do
        patch api_employer_employee_path(employer, employee), params: update_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(employee.reload.first_name).to eq("Updated Name")
      end
    end

    context "when unauthorized" do
      before { patch api_employer_employee_path(employer, employee), params: update_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "DELETE employees/:id" do
    context "when admin deletes an employee" do
      it "successfully deletes the employee" do
        expect {
          delete api_employer_employee_path(employer, employee), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Employee.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when actuary attempts to delete an employee" do
      before { delete api_employer_employee_path(employer, employee), headers: { Authorization: "Bearer #{actuary_user_token}" } }
      it_behaves_like "an unauthorized response"
    end

    context "when unauthorized" do
      before { delete api_employer_employee_path(employer, employee) }
      it_behaves_like "an unauthorized response"
    end
  end
end
