require "rails_helper"

RSpec.describe "Providers API", type: :request do
  include_context "with authenticated users"

  let!(:providers) { create_list(:provider, 3) }
  let!(:provider) { Provider.first }

  describe "GET /providers" do
    context "when admin authenticated" do
      it "returns a list of providers" do
        get api_providers_path, headers: { Authorization: "Bearer #{admin_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)

        expect(response_body.size).to eq(providers.count)
      end
    end

    context "when employee authenticated" do
      it "returns a list of providers" do
        get api_providers_path, headers: { Authorization: "Bearer #{actuary_user_token}" }
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)

        expect(response_body.size).to eq(providers.count)
      end
    end

    context "when not authenticated" do
      before do
        get api_providers_path
      end
      it_behaves_like "an unauthorized response"
    end
  end

  describe "POST /providers" do
    let(:valid_params) { { provider: { name: "ABC Health", address: "123 Main St", phone: "5145551234" } } }

    context "when admin creates a provider" do
      it "creates a provider successfully" do
        expect { post api_providers_path,
                      params: valid_params,
                      headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Provider.count }.by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when employee creates a provider" do
      it "creates a provider successfully" do
        expect { post api_providers_path,
                      params: valid_params,
                      headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { Provider.count }.by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when not authenticated" do
      it "returns a unauthorized response" do
        expect { post api_providers_path, params: valid_params }.not_to change { Provider.count }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /providers/:id" do
    let(:update_params) { { provider: { name: "Updated Name" } } }

    context "when admin updates a provider" do
      it "updates the provider successfully" do
        expect {
          patch api_provider_path(provider),
                params: update_params,
                headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { provider.reload.name }.to("Updated Name")

        expect(response).to have_http_status(:ok)
      end
    end

    context "when employee updates a provider" do
      it "updates the provider successfully" do
        expect {
          patch api_provider_path(provider),
                params: update_params,
                headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.to change { provider.reload.name }.to("Updated Name")

        expect(response).to have_http_status(:ok)
      end
    end

    context "when unauthorized" do
      it "returns a unauthorized response" do
        expect { patch api_provider_path(provider), params: update_params }.not_to change { Provider.count }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /providers/:id" do
    context "when admin deletes a provider" do
      it "deletes the provider successfully" do
        expect {
          delete api_provider_path(provider), headers: { Authorization: "Bearer #{admin_token}" }
        }.to change { Provider.count }.by(-1)

        expect(response).to have_http_status(:no_content)
        expect(Provider.exists?(provider.id)).to be_falsey
      end
    end

    context "when employee tries to delete" do
      it "returns an unauthorized response" do
        expect {
          delete api_provider_path(provider), headers: { Authorization: "Bearer #{actuary_user_token}" }
        }.not_to change { Provider.count }

        expect(response).to have_http_status(:unauthorized)
        expect(Provider.exists?(provider.id)).to be_truthy
      end
    end
  end
end
