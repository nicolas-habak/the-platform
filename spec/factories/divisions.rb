FactoryBot.define do
  factory :division do
    association :employer
    association :policy
    name { "Division A" }
    code { "A" }
  end
end
