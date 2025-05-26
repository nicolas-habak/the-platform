FactoryBot.define do
  factory :bill do
    employer { nil }
    date_issued { "2025-05-26" }
    billing_period_start { "2025-05-26" }
    billing_period_end { "2025-05-26" }
  end
end
