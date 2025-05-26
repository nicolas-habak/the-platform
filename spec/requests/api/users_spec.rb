require 'rails_helper'

RSpec.describe "Users API", type: :request do
  include_context "with authenticated users"

  describe 'GET /api/users' do
    context 'with valid token' do
      context 'admin user' do
        before do
          get api_users_path, headers: { Authorization: "Bearer #{admin_token}" }
        end

        it 'returns a list of users' do
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)

          expect(response_body).to be_an(Array)
          expect(response_body.length).to eq(users.count)

          response_body.each do |user|
            expect(user).to have_key('id')
            expect(user).to have_key('email')
            expect(user).not_to have_key('token')
            expect(user['user_profiles']).to be_an(Array)
            expect(user['user_profiles'].first).to have_key('id')
            expect(user['user_profiles'].first).to have_key('first_name')
            expect(user['user_profiles'].first).to have_key('last_name')
          end
        end
      end

      context 'employee user' do
        before do
          get api_users_path, headers: { Authorization: "Bearer #{actuary_user_token}" }
        end

        it_behaves_like "an unauthorized response"
      end
    end

    context 'with invalid token' do
      before do
        get api_users_path, headers: { 'Authorization' => 'Bearer invalidtoken123' }
      end

      it_behaves_like "an unauthorized response"
    end

    context 'without token' do
      before do
        get api_users_path
      end

      it_behaves_like "an unauthorized response"
    end
  end

  describe 'GET /api/users/:id' do
    context 'with valid token' do
      context 'as an admin user' do
        it 'returns the specified user details' do
          get api_user_path(actuary_user), headers: { Authorization: "Bearer #{admin_token}" }
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('id' => actuary_user.id)
        end

        before { get api_user_path(99999), headers: { Authorization: "Bearer #{admin_token}" } }
        it "returns not found" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'as an employee viewing their own record' do
        before do
          get api_user_path(actuary_user), headers: { Authorization: "Bearer #{actuary_user_token}" }
        end

        it 'returns the employee’s own details' do
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('id' => actuary_user.id)
        end
      end

      context 'as an employee attempting to view another user’s record' do
        before do
          get api_user_path(admin_user), headers: { Authorization: "Bearer #{actuary_user_token}" }
        end

        it_behaves_like "an unauthorized response"
      end
    end

    context 'with invalid token' do
      before do
        get api_user_path(actuary_user), headers: { 'Authorization' => 'Bearer invalidtoken123' }
      end

      it_behaves_like "an unauthorized response"
    end

    context 'without token' do
      before do
        get api_user_path(actuary_user)
      end

      it_behaves_like "an unauthorized response"
    end
  end

  describe 'PUT /api/users/:id' do
    context 'with valid token' do
      let(:old_email) { actuary_user.email }
      let(:new_email) { 'employee_new@example.com' }
      let(:update_params) do
        { user: { email: new_email, password: 'newpassword' } }
      end

      context 'as an admin user updating any user' do

        it 'updates the user with all permitted attributes' do
          expect {
            put api_user_path(actuary_user),
                headers: { Authorization: "Bearer #{actuary_user_token}" },
                params: update_params
            actuary_user.reload
          }.to change { actuary_user.email }.from(old_email).to(new_email)

          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('email' => new_email)
        end
      end

      context 'as an employee updating their own record' do
        before do
          put api_user_path(actuary_user),
              headers: { Authorization: "Bearer #{actuary_user_token}" },
              params: update_params
        end

        it 'updates only permitted attributes (email and password)' do
          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('email' => new_email)
        end
      end

      context 'as an employee attempting to update another user' do
        before do
          put api_user_path(admin_user),
              headers: { Authorization: "Bearer #{actuary_user_token}" },
              params: update_params
        end

        it_behaves_like "an unauthorized response"

        it "does not change the record" do
          expect { admin_user.reload }.not_to change { admin_user.attributes }
        end
      end
    end

    context 'with invalid parameters' do
      context 'as an admin updating a user with invalid email' do
        let(:update_params) { { user: { email: '', password: 'newpassword' } } }

        before do
          put api_user_path(actuary_user),
              headers: { Authorization: "Bearer #{admin_token}" },
              params: update_params
        end

        it 'returns unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
          response_body = JSON.parse(response.body)
          expect(response_body).to have_key('errors')
        end

        it 'does not change the record' do
          expect { actuary_user.reload }.not_to change { actuary_user.attributes }
        end
      end
    end

    context 'with invalid token' do
      before do
        put api_user_path(actuary_user),
            headers: { 'Authorization' => 'Bearer invalidtoken123' },
            params: { user: { email: 'foo@example.com' } }
      end

      it 'does not change the record' do
        expect { actuary_user.reload }.not_to change { actuary_user.attributes }
      end

      it_behaves_like "an unauthorized response"
    end

    context 'without token' do
      before do
        put api_user_path(actuary_user),
            params: { user: { email: 'foo@example.com' } }
      end

      it 'does not change the record' do
        expect { actuary_user.reload }.not_to change { actuary_user.attributes }
      end

      it_behaves_like "an unauthorized response"
    end
  end

  describe 'POST /api/users' do
    let(:new_user_email) { 'newuser@example.com' }
    let(:new_user_params) do
      { user: { email: new_user_email, password: 'secretpassword' } }
    end

    context 'with valid token' do
      context 'as an admin user' do
        it 'creates a new user' do
          expect {
            post api_users_path,
                 headers: { Authorization: "Bearer #{admin_token}" },
                 params: new_user_params
          }.to change { User.count }.by(1)

          expect(response).to have_http_status(:created)
          response_body = JSON.parse(response.body)
          expect(response_body).to include("email" => new_user_email)
        end
      end

      context 'as an employee user' do
        before do
          post api_users_path,
               headers: { Authorization: "Bearer #{actuary_user_token}" },
               params: new_user_params
        end

        it_behaves_like "an unauthorized response"

        it "does not create a new user" do
          expect { post api_users_path,
                        headers: { Authorization: "Bearer #{actuary_user_token}" },
                        params: new_user_params
          }.not_to change { User.count }
        end
      end
    end

    context 'with invalid token' do
      before do
        post api_users_path,
             headers: { Authorization: "Bearer invalidtoken123" },
             params: new_user_params
      end

      it_behaves_like "an unauthorized response"

      it "does not create a new user" do
        expect { post api_users_path,
                      headers: { Authorization: "Bearer invalidtoken123" },
                      params: new_user_params
        }.not_to change { User.count }
      end
    end

    context 'without token' do
      before do
        post api_users_path,
             params: new_user_params
      end

      it_behaves_like "an unauthorized response"

      it "does not create a new user" do
        expect { post api_users_path,
                      params: new_user_params
        }.not_to change { User.count }
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { user: { email: '', password: 'secret' } } }

      it 'returns unprocessable entity status' do
        expect { post api_users_path,
             headers: { Authorization: "Bearer #{admin_token}" },
             params: invalid_params
        }.not_to change { User.count }

        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('errors')
      end
    end
  end
end
