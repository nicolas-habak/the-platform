FactoryBot.define do
  factory :role do
    name { "employee" }

    trait :admin do
      name { "admin" }
    end
  end
end
