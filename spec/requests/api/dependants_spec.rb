require "rails_helper"

RSpec.describe "Dependants API", type: :request do
  include_context "with authenticated users"

  let!(:employer) { create(:employer) }
  let!(:provider) { create(:provider) }
  let!(:policy)   { create(:policy, provider: provider, employer: employer) }
  let!(:division) { create(:division, employer: employer, policy: policy) }
  let!(:employee) { create(:employee, employer: employer) }
  let!(:insurance_profile) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today) }
  let!(:dependants) { create_list(:dependant, 3, insurance_profile: insurance_profile) }
  let!(:dependant) { dependants.first }

  let(:valid_params) do
    {
      dependant: {
        insurance_profile_id: insurance_profile.id,
        name: Faker::Name,
        date_of_birth: Faker::Date.birthday(min_age: 0, max_age: 18),
        relation: "child",
        has_disability: false
      }
    }
  end

  describe "GET /api/employers/:employer_id/employees/:employee_id/dependants" do
    context "when authenticated as admin" do
      it "returns all dependants for an employee" do
        get api_employer_employee_dependants_path(employer, employee), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(dependants.count)
      end
    end

    context "when authenticated as actuary" do
      it "returns all dependants for an employee" do
        get api_employer_employee_dependants_path(employer, employee), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(dependants.count)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_dependants_path(employer, employee) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "GET /api/employers/:employer_id/employees/:employee_id/dependants/:id" do
    context "when admin views a dependant" do
      it "returns the dependant" do
        get api_employer_employee_dependant_path(employer, employee, dependant), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("id" => dependant.id)
      end
    end
    context "when actuary views a dependant" do
      it "returns the dependant" do
        get api_employer_employee_dependant_path(employer, employee, dependant), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("id" => dependant.id)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_dependant_path(employer, employee, dependant) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST /api/employers/:employer_id/employees/:employee_id/dependants" do
    context "when admin creates a dependant" do
      it "successfully creates a dependant" do
        expect {
          post api_employer_employee_dependants_path(employer, employee), params: valid_params, headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Dependant.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when admin creates a dependant" do
      it "successfully creates a dependant" do
        expect {
          post api_employer_employee_dependants_path(employer, employee), params: valid_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { Dependant.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthorized" do
      before { post api_employer_employee_dependants_path(employer, employee), params: valid_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "PATCH /api/employers/:employer_id/employees/:employee_id/dependants/:id" do
    let(:update_params) { { dependant: { name: "Updated Name" } } }

    context "when admin updates a dependant" do
      it "successfully updates the dependant" do
        patch api_employer_employee_dependant_path(employer, employee, dependant), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(dependant.reload.name).to eq("Updated Name")
      end
    end

    context "when admin updates a dependant" do
      it "successfully updates the dependant" do
        patch api_employer_employee_dependant_path(employer, employee, dependant), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(dependant.reload.name).to eq("Updated Name")
      end
    end

    context "when actuary updates a dependant" do
      it "successfully updates the dependant" do
        patch api_employer_employee_dependant_path(employer, employee, dependant), params: update_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(dependant.reload.name).to eq("Updated Name")
      end
    end

    context "when unauthorized" do
      before { patch api_employer_employee_dependant_path(employer, employee, dependant), params: update_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "DELETE /api/employers/:employer_id/employees/:employee_id/dependants/:id" do
    context "when admin deletes a dependant" do
      it "successfully deletes the dependant" do
        expect {
          delete api_employer_employee_dependant_path(employer, employee, dependant), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Dependant.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    it "successfully deletes the dependant" do
      expect {
        delete api_employer_employee_dependant_path(employer, employee, dependant), headers: { Authorization: "Bearer #{actuary_user_token}" }
      }.to change { Dependant.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    context "when unauthorized" do
      before { delete api_employer_employee_dependant_path(employer, employee, dependant) }
      it_behaves_like "an unauthorized response"
    end
  end
end
