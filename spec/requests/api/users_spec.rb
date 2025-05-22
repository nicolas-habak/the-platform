require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let!(:users) do
    [ create(:admin_user) ] + create_list(:employee_user, 4)
  end

  let!(:admin_user) { User.first }
  let!(:employee_user) { User.second }

  let!(:admin_token) { admin_user.regenerate_token && admin_user.token }
  let!(:employee_token) { employee_user.regenerate_token && employee_user.token }

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
          expect(response_body.length).to eq(5)

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
          get api_users_path, headers: { Authorization: "Bearer #{employee_token}" }
        end

        include_examples "an unauthorized response"
      end
    end

    context 'with invalid token' do
      before do
        get api_users_path, headers: { 'Authorization' => 'Bearer invalidtoken123' }
      end

      include_examples "an unauthorized response"
    end

    context 'without token' do
      before do
        get api_users_path
      end

      include_examples "an unauthorized response"
    end
  end

  describe 'GET /api/users/:id' do
    context 'with valid token' do
      context 'as an admin user' do
        before do
          get api_user_path(employee_user), headers: { Authorization: "Bearer #{admin_token}" }
        end

        it 'returns the specified user details' do
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('id' => employee_user.id)
        end
      end

      context 'as an employee viewing their own record' do
        before do
          get api_user_path(employee_user), headers: { Authorization: "Bearer #{employee_token}" }
        end

        it 'returns the employee’s own details' do
          expect(response).to have_http_status(200)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('id' => employee_user.id)
        end
      end

      context 'as an employee attempting to view another user’s record' do
        before do
          get api_user_path(admin_user), headers: { Authorization: "Bearer #{employee_token}" }
        end

        include_examples "an unauthorized response"
      end
    end

    context 'with invalid token' do
      before do
        get api_user_path(employee_user), headers: { 'Authorization' => 'Bearer invalidtoken123' }
      end

      include_examples "an unauthorized response"
    end

    context 'without token' do
      before do
        get api_user_path(employee_user)
      end

      include_examples "an unauthorized response"
    end
  end

  describe 'PUT /api/users/:id' do
    context 'with valid token' do
      let(:old_email) { employee_user.email }
      let(:new_email) { 'employee_new@example.com' }
      let(:update_params) do
        { user: { email: new_email, password: 'newpassword' } }
      end

      context 'as an admin user updating any user' do

        it 'updates the user with all permitted attributes' do
          expect {
            put api_user_path(employee_user),
                headers: { Authorization: "Bearer #{employee_token}" },
                params: update_params
            employee_user.reload
          }.to change { employee_user.email }.from(old_email).to(new_email)

          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body)
          expect(response_body).to include('email' => new_email)
        end
      end

      context 'as an employee updating their own record' do
        before do
          put api_user_path(employee_user),
              headers: { Authorization: "Bearer #{employee_token}" },
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
              headers: { Authorization: "Bearer #{employee_token}" },
              params: update_params
        end

        include_examples "an unauthorized response"
      end
    end

    context 'with invalid parameters' do
      context 'as an admin updating a user with invalid email' do
        let(:update_params) { { user: { email: '', password: 'newpassword' } } }

        before do
          put api_user_path(employee_user),
              headers: { Authorization: "Bearer #{admin_token}" },
              params: update_params
        end

        it 'returns unprocessable entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
          response_body = JSON.parse(response.body)
          expect(response_body).to have_key('errors')
        end
      end
    end

    context 'with invalid token' do
      before do
        put api_user_path(employee_user),
            headers: { 'Authorization' => 'Bearer invalidtoken123' },
            params: { user: { email: 'foo@example.com' } }
      end

      include_examples "an unauthorized response"
    end

    context 'without token' do
      before do
        put api_user_path(employee_user),
            params: { user: { email: 'foo@example.com' } }
      end

      include_examples "an unauthorized response"
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
               headers: { Authorization: "Bearer #{employee_token}" },
               params: new_user_params
        end

        include_examples "an unauthorized response"
      end
    end

    context 'with invalid token' do
      before do
        post api_users_path,
             headers: { Authorization: "Bearer invalidtoken123" },
             params: new_user_params
      end

      include_examples "an unauthorized response"
    end

    context 'without token' do
      before do
        post api_users_path,
             params: new_user_params
      end

      include_examples "an unauthorized response"
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { user: { email: '', password: 'secret' } } }

      before do
        post api_users_path,
             headers: { Authorization: "Bearer #{admin_token}" },
             params: invalid_params
      end

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('errors')
      end
    end
  end

end
