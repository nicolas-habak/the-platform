require "rails_helper"

RSpec.describe "Divisions API", type: :request do
  include_context "with authenticated users"

  let!(:employer) { create(:employer) }
  let!(:provider) { create(:provider) }
  let!(:policy)   { create(:policy, provider: provider, employer: employer) }
  let!(:division) { create(:division, :with_policies, employer: employer) }

  let(:valid_params) do
    {
      division: {
        name: "New Division",
        code: "ND",
        employer_id: employer.id,
        policy_ids: [ policy.id ]
      }
    }
  end

  describe "GET /api/employers/:employer_id/divisions" do
    context "when authenticated as admin" do
      it "returns all divisions" do
        get api_employer_divisions_path(employer), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.size).to eq(Division.count)
      end
    end

    context "when authenticated as actuary" do
      it "returns all divisions" do
        get api_employer_divisions_path(employer), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.size).to eq(Division.count)
      end
    end

    context "when unauthorized" do
      before { get api_employer_divisions_path(employer) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "GET /api/employers/:employer_id/divisions/:id" do
    context "when admin views a division" do
      it "returns the division" do
        get api_employer_division_path(employer, division), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include("id" => division.id)
      end
    end

    context "when actuary views a division" do
      it "returns the division" do
        get api_employer_division_path(employer, division), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include("id" => division.id)
      end
    end

    context "when admin tries to view a non-existent division" do
      it "returns a not found response" do
        get api_employer_division_path(employer, 99999), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when unauthorized" do
      before { get api_employer_division_path(employer, division) }
      it_behaves_like "an unauthorized response"
    end

    context "when inexistent and unauthorized" do
      before { get api_employer_division_path(employer, 99999) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST /api/employers/:employer_id/divisions" do
    context "when admin creates a division" do
      it "successfully creates a division" do
        expect {
          post api_employer_divisions_path(employer), params: valid_params, headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Division.count }.by(1)

        division = Division.last
        expect(division.name).to eq("New Division")
        expect(division.code).to eq("ND")
        expect(division.employer_id).to eq(employer.id)
        expect(division.policies.count).to eq(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when actuary creates a division" do
      it "successfully creates a division" do
        expect {
          post api_employer_divisions_path(employer), params: valid_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { Division.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthorized" do
      before { post api_employer_divisions_path(employer), params: valid_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "PATCH /api/employers/:employer_id/divisions/:id" do
    let(:update_params) { { division: { name: "Updated Division" } } }

    context "when admin updates a division" do
      it "successfully updates the division" do
        patch api_employer_division_path(employer, division), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(division.reload.name).to eq("Updated Division")
      end
    end

    context "when actuary updates a division" do
      it "successfully updates the division" do
        patch api_employer_division_path(employer, division), params: update_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(division.reload.name).to eq("Updated Division")
      end
    end

    context "when unauthorized" do
      before { patch api_employer_division_path(employer, division), params: update_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "DELETE /api/employers/:employer_id/divisions/:id" do
    context "when admin deletes a division" do
      it "successfully deletes the division" do
        expect {
          delete api_employer_division_path(employer, division), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Division.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when actuary tries to delete a division" do
      before do
        delete api_employer_division_path(employer, division), headers: { Authorization: "Bearer #{actuary_user_token}" }
      end
      it_behaves_like "an unauthorized response"
    end

    context "when unauthorized" do
      before { delete api_employer_division_path(employer, division) }
      it_behaves_like "an unauthorized response"
    end
  end
end
