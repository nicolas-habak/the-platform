FactoryBot.define do
  factory :role do
    name { "actuary" }

    trait :admin do
      name { "admin" }
    end
  end
end
