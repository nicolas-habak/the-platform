require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, password: "password123") }

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'returns a token' do
        post login_path params: {
          email: user.email,
          password: 'password123'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['token']).to eq(user.reload.token)
      end
    end

    context 'with invalid password' do
      it 'returns unauthorized' do
        post login_path, params: {
          email: user.email,
          password: 'wrongpassword'
        }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['token']).to be_nil
      end
    end

    context 'with non-existent user' do
      it 'returns unauthorized' do
        post login_path, params: {
          email: 'nonexistent@example.com',
          password: 'password123'
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
