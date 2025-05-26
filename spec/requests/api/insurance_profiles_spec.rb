require "rails_helper"

RSpec.describe "InsuranceProfiles API", type: :request do
  include_context "with authenticated users"

  let!(:employer) { create(:employer) }
  let!(:provider) { create(:provider) }
  let!(:policy)   { create(:policy, provider: provider, employer: employer) }
  let!(:division) { create(:division, :with_policies, employer: employer) }
  let!(:employee) { create(:employee, employer: employer) }
  let!(:insurance_profile) { create(:insurance_profile, employee: employee, division: division, start_date: Date.today) }

  let(:valid_params) do
    {
      insurance_profile: {
        life: true,
        smoker: false,
        health: "single",
        dental: "family",
        start_date: Date.today,
        end_date: 1.year.from_now,
        employee_id: employee.id,
        division_id: division.id
      }
    }
  end

  describe "GET /insurance_profiles" do
    context "when authenticated as admin" do
      it "returns all insurance profiles" do
        get api_employer_employee_insurance_profiles_path(employer, employee), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.size).to eq(InsuranceProfile.count)
      end
    end

    context "when authenticated as actuary" do
      it "returns all insurance profiles" do
        get api_employer_employee_insurance_profiles_path(employer, employee), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.size).to eq(InsuranceProfile.count)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_insurance_profiles_path(employer, employee) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "GET /insurance_profiles/:id" do
    context "when admin views a profile" do
      it "returns the insurance profile" do
        get api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include("id" => insurance_profile.id)
      end
    end

    context "when admin tries to view a non-existent profile" do
      it "returns a not found response" do
        get api_employer_employee_insurance_profile_path(employer, employee, 99999), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when an actuary views a profile" do
      it "returns the insurance profile" do
        get api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include("id" => insurance_profile.id)
      end
    end

    context "when actuary tries to view a non-existent profile" do
      it "returns a not found response" do
        get api_employer_employee_insurance_profile_path(employer, employee, 99999), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when unauthorized" do
      before { get api_employer_employee_insurance_profile_path(employer, employee, insurance_profile) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST /insurance_profiles" do
    context "when admin creates an insurance profile" do
      it "successfully creates a profile" do
        expect {
          post api_employer_employee_insurance_profiles_path(employer, employee), params: valid_params, headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { InsuranceProfile.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when an actuary creates an insurance profile" do
      it "successfully creates a profile" do
        expect {
          post api_employer_employee_insurance_profiles_path(employer, employee), params: valid_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { InsuranceProfile.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthorized" do
      before { post api_employer_employee_insurance_profiles_path(employer, employee), params: valid_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "PATCH /insurance_profiles/:id" do
    let(:update_params) { { insurance_profile: { health: "family" } } }

    context "when admin updates a profile" do
      it "successfully updates the insurance profile" do
        patch api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(insurance_profile.reload.health).to eq("family")
      end
    end

    context "when an actuary updates a profile" do
      it "successfully updates the insurance profile" do
        patch api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), params: update_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(insurance_profile.reload.health).to eq("family")
      end
    end

    context "when unauthorized" do
      before { patch api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), params: update_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "DELETE /insurance_profiles/:id" do
    context "when admin deletes a profile" do
      it "successfully deletes the insurance profile" do
        expect {
          delete api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { InsuranceProfile.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when actuary tries to deletes a profile" do
      before { delete api_employer_employee_insurance_profile_path(employer, employee, insurance_profile), headers: { Authorization: "Bearer #{actuary_user_token}" } }
      it_behaves_like "an unauthorized response"
    end

    context "when unauthorized" do
      before { delete api_employer_employee_insurance_profile_path(employer, employee, insurance_profile) }
      it_behaves_like "an unauthorized response"
    end
  end
end
