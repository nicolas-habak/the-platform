FactoryBot.define do
  factory :billing_entry do
    bill { nil }
    insurance_profile { nil }
    life_benefit { "MyString" }
    life { "9.99" }
    health_benefit { "MyString" }
    health { "9.99" }
    dental_benefit { "MyString" }
    dental { "9.99" }
    smoker_benefit { false }
    smoker { "9.99" }
  end
end
