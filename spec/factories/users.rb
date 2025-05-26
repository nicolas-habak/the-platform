FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 10, max_length: 20, mix_case: true, special_characters: true) }
    token { SecureRandom.hex(20) }

    after(:create) do |user|
      create(:user_profile, user: user)
    end
  end

  factory :admin_user, parent: :user do
    after(:create) do |user|
      admin_role = create(:role, name: 'admin')
      create(:user_role, user: user, role: admin_role)
    end
  end

  factory :actuary_user, parent: :user do
    after(:create) do |user|
      actuary_role = Role.find_or_create_by!(name: "actuary")
      create(:user_role, user: user, role: actuary_role)
    end
  end
end
