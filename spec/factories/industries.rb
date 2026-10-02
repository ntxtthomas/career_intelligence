FactoryBot.define do
  factory :industry do
    sequence(:name) { |n| "Industry #{n}" }

    factory :segment do
      association :parent, factory: :industry
    end
  end
end
