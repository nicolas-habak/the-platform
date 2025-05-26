FactoryBot.define do
  factory :policy do
    association :provider
    association :employer
    number { "POL-#{Faker::Number.number(digits: 3)}" }
    life { nil }
    health_single { nil }
    health_family { nil }
    dental_single { nil }
    dental_family { nil }

    trait :with_life do
      life { 200 }
    end

    trait :with_health do
      health_single { 250 }
      health_family { 450 }
    end
    trait :with_dental do
      health_single { 275 }
      health_family { 550 }
    end

    trait :past_policy do
      start_date { 1.year.ago }
      end_date { 1.day.ago }
    end

    trait :present_policy do
      start_date { Date.today }
      end_date { 1.year.from_now }
    end

    trait :future_policy do
      start_date { 1.year.from_now + 1.day }
      end_date { 2.years.from_now }
    end
  end
end
