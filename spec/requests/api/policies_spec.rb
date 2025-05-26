require "rails_helper"

RSpec.describe "Policies API", type: :request do
  include_context "with authenticated users"

  let!(:provider) { create(:provider) }
  let!(:employer) { create(:employer) }
  let!(:policy) { create(:policy, provider: provider, employer: employer) }

  let(:valid_params) do
    {
      policy: {
        number: "POL-5678",
        life: 2.0,
        health_single: 2.0,
        health_family: 2.0,
        dental_single: 2.0,
        dental_family: 2.0,
        start_date: Time.current.to_date,
        end_date: 1.year.from_now.to_date,
        provider_id: provider.id
      }
    }
  end

  describe "GET /policies" do
    context "when authenticated as admin" do
      it "returns all policies" do
        get api_employer_policies_path(employer), headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.size).to eq(Policy.count)
      end
    end

    context "when authenticated as employee" do
      it "returns all policies" do
        get api_employer_policies_path(employer), headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body.size).to eq(Policy.count)
      end
    end

    context "when unauthorized" do
      before { get api_employer_policies_path(employer) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "GET /policies/:id" do
    it "returns a policy for admin" do
      get api_employer_policy_path(employer, policy), headers: { Authorization: "Bearer #{admin_token}" }
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body).to include('number' => policy.number)
    end

    it "returns a policy for employee" do
      get api_employer_policy_path(employer, policy), headers: { Authorization: "Bearer #{actuary_user_token}" }
      response_body = JSON.parse(response.body)
      expect(response_body).to include('number' => policy.number)
    end

    context "when unauthorized" do
      before { get api_employer_policy_path(employer, policy) }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST /policies" do
    context "when admin creates a policy" do
      it "successfully creates a policy" do
        expect {
          post api_employer_policies_path(employer), params: valid_params, headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Policy.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when employee creates a policy" do
      it "successfully creates a policy" do
        expect {
          post api_employer_policies_path(employer), params: valid_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { Policy.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when unauthorized" do
      before { post api_employer_policies_path(employer), params: valid_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "PATCH /policies/:id" do
    let(:update_params) { { policy: { number: "UPDATED-POLICY" } } }

    context "when admin updates a policy" do
      it "successfully updates the policy" do
        patch api_employer_policy_path(employer, policy), params: update_params, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        expect(policy.reload.number).to eq("UPDATED-POLICY")
      end
    end

    context "when employee updates a policy" do
      it "successfully updates the policy" do
        patch api_employer_policy_path(employer, policy), params: update_params, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        expect(policy.reload.number).to eq("UPDATED-POLICY")
      end
    end

    context "when unauthorized" do
      before { patch api_employer_policy_path(employer, policy), params: update_params }
      it_behaves_like "an unauthorized response"
    end
  end

  describe "DELETE /policies/:id" do
    context "when admin deletes a policy" do
      it "successfully deletes the policy" do
        expect {
          delete api_employer_policy_path(employer, policy), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Policy.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when employee tries to delete a policy" do
      before do
        delete api_employer_policy_path(employer, policy), headers: { Authorization: "Bearer #{actuary_user_token}" }
      end
      it "is unauthorized" do
        expect {
          delete api_employer_policy_path(employer, policy), headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.not_to change { Policy.count }

      end

      it_behaves_like "an unauthorized response"
    end

    context "when unauthorized" do
      before { delete api_employer_policy_path(employer, policy) }
      it_behaves_like "an unauthorized response"
    end
  end
end
