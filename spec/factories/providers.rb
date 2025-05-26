FactoryBot.define do
  factory :provider do
    name { "#{Faker::Company.name} #{[ 'Assurance', 'Financial Group', 'Insurance' ].sample}" }
    address { Faker::Address.full_address }
    phone { "9415283713" }

    trait :full_policy do
      after(:create) do |provider|
        create(:policy, :past_policy, provider: provider)
        create(:policy, :present_policy, provider: provider)
        create(:policy, :future_policy, provider: provider)
      end
    end
  end
end
