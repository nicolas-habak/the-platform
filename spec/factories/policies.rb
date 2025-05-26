FactoryBot.define do
  factory :policy do
    association :provider
    association :employer
    number { "POL-1234" }
    life { 1.5 }
    health_single { 1.5 }
    health_family { 1.5 }
    dental_single { 1.5 }
    dental_family { 1.5 }

    trait :past_policy do
      start_date { 1.year.ago }
      end_date { 1.day.ago }
    end

    trait :present_policy do
      start_date { Date.today }
      end_date { 1.year.from_now }
    end

    trait :future_policy do
      start_date { 1.year.from_now }
      end_date { 2.years.from_now }
    end
  end
end
