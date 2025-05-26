FactoryBot.define do
  factory :insurance_profile do
    association :employee
    association :division
    life { false }
    health { nil }
    dental { nil }
    smoker { false }
    start_date { Faker::Date.backward(days: 365) }
  end
end
