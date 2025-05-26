FactoryBot.define do
  factory :employer do
    name { Faker::Company.name }
    address { Faker::Address.full_address }
  end
end
