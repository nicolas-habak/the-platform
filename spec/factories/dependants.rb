FactoryBot.define do
  factory :dependant do
    association :insurance_profile
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(min_age: 0, max_age: 18) }
    relation { %w[child spouse].sample }
    has_disability { Faker::Boolean.boolean }
  end
end
