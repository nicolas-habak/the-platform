require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let!(:users) do
    create_list(:user, 5) do |user|
      create(:user_profile, user: user)
    end
  end

  let!(:user) { User.first }
  let!(:token) { user.regenerate_token && user.token }

  describe 'GET /api/users' do
    context 'with valid token' do
      before do
        get '/api/users', headers: { Authorization: "Bearer #{token}" }
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

    context 'with invalid token' do
      before do
        get '/api/users', headers: { 'Authorization' => 'Bearer invalidtoken123' }
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
        expect(response_body['error']).to eq('Unauthorized')
      end
    end

    context 'without token' do
      before do
        get '/api/users'
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('error')
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end
end
