RSpec.shared_context "with authenticated users" do
  let!(:users) { [ create(:admin_user) ] + create_list(:actuary_user, 4) }
  let!(:admin_user) { users.first }
  let!(:actuary_user) { users.second }

  let!(:admin_token) { admin_user.regenerate_token && admin_user.token }
  let!(:actuary_user_token) { actuary_user.regenerate_token && actuary_user.token }
end
