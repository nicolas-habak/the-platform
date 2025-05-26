FactoryBot.define do
  factory :core_profile do
    association :employee
    address { Faker::Address.full_address }
    salary { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    hours_per_week { Faker::Number.between(from: 20, to: 40) }
    start_date { Faker::Date.backward(days: 365) }
    end_date { Faker::Date.forward(days: 365) }

    # Ensures end_date is always after start_date
    after(:build) do |core_profile|
      core_profile.end_date = core_profile.start_date + rand(30..365).days if !core_profile.end_date.blank? && core_profile.end_date < core_profile.start_date
    end
  end
end
