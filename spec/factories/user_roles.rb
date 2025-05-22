FactoryBot.define do
  factory :user_role do
    user { nil }
    role { nil }
    start_date { Time.now }
    end_date { nil }

    trait :future_end_date do
      end_date { 1.month.from_now }
    end

    trait :past_end_date do
      start_date { 1.month.ago }
      end_date { 1.day.ago }
    end


  end
end
