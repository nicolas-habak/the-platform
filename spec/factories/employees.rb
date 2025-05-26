FactoryBot.define do
  factory :employee do
    association :employer
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sex { Faker::Gender.binary_type == 'Male' ? 'm' : 'f' }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end
