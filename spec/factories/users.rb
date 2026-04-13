FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }

    trait :demo do
      demo { true }
    end
  end
end
