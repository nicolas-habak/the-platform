require "rails_helper"

RSpec.describe "CoreProfiles API", type: :request do
  include_context "with authenticated users"

  let!(:employer) { create(:employer) }
  let!(:employee) { create(:employee, employer: employer) }
  let!(:core_profiles) { create_list(:core_profile, 3, employee: employee) }
  let!(:other_employee) { create(:employee, employer: employer) }
  let!(:other_core_profiles) { create_list(:core_profile, 3, employee: other_employee) }
  let!(:core_profile) { core_profiles.first }

  let(:valid_params) do
    {
      core_profile: {
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        address: Faker::Address.full_address,
        salary: Faker::Number.between(from: 50000, to: 100000),
        start_date: Date.today,
        employee_id: employee.id
      }
    }
  end

  describe "GET /api/employers/:employer_id/employees/:employee_id/core_profiles" do
    context "when authenticated as admin" do
      it "returns all core profiles for the employee" do
        get api_employer_employee_core_profiles_path(employer, employee), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(core_profiles.count)
      end
    end

    context "when authenticated as actuary" do
      it "returns all core profiles for the employee" do
        get api_employer_employee_core_profiles_path(employer, employee), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(core_profiles.count)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_core_profiles_path(employer, employee) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "GET /api/employers/:employer_id/employees/:employee_id/core_profiles/:id" do
    context "when admin views a core profile" do
      it "returns the core profile" do
        get api_employer_employee_core_profile_path(employer, employee, core_profile), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("id" => core_profile.id)
      end
    end

    context "when actuary views a core profile" do
      it "returns the core profile" do
        get api_employer_employee_core_profile_path(employer, employee, core_profile), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("id" => core_profile.id)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_core_profile_path(employer, employee, core_profile) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST /api/employers/:employer_id/employees/:employee_id/core_profiles" do
    context "when admin creates a core profile" do
      it "successfully creates a core profile" do
        expect {
          post api_employer_employee_core_profiles_path(employer, employee), params: valid_params, headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { CoreProfile.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when actuary creates a core profile" do
      it "successfully creates a core profile" do
        expect {
          post api_employer_employee_core_profiles_path(employer, employee), params: valid_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { CoreProfile.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthorized" do
      before { post api_employer_employee_core_profiles_path(employer, employee), params: valid_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "PATCH /api/employers/:employer_id/employees/:employee_id/core_profiles/:id" do
    let(:update_params) { { core_profile: { address: "Updated Address" } } }

    context "when admin updates a core profile" do
      it "successfully updates the core profile" do
        patch api_employer_employee_core_profile_path(employer, employee, core_profile), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(core_profile.reload.address).to eq("Updated Address")
      end
    end

    context "when actuary updates a core profile" do
      it "successfully updates the core profile" do
        patch api_employer_employee_core_profile_path(employer, employee, core_profile), params: update_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(core_profile.reload.address).to eq("Updated Address")
      end
    end

    context "when unauthorized" do
      before { patch api_employer_employee_core_profile_path(employer, employee, core_profile), params: update_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "DELETE /api/employers/:employer_id/employees/:employee_id/core_profiles/:id" do
    context "when admin deletes a core profile" do
      it "successfully deletes the core profile" do
        expect {
          delete api_employer_employee_core_profile_path(employer, employee, core_profile), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { CoreProfile.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when actuary attempts to delete a core profile" do
      before { delete api_employer_employee_core_profile_path(employer, employee, core_profile), headers: { Authorization: "Bearer #{actuary_user_token}" } }
      it_behaves_like "an unauthorized response"
    end

    context "when unauthorized" do
      before { delete api_employer_employee_core_profile_path(employer, employee, core_profile) }
      it_behaves_like "an unauthorized response"
    end
  end
end
