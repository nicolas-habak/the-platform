FactoryBot.define do
  factory :division do
    association :employer

    name { Faker::Company.name }
    code { "DIV#{Faker::Number.number(digits: 2)}" }

    trait :with_policies do
      after(:create) do |division|
        division.policies << create_list(:policy, 3, employer: division.employer)
      end
    end
  end
end
