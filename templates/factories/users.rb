FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email
    password "password"
    password_confirmation "password"

    trait :confirmed do
      initialize_with do
        user = User.new
        user.skip_confirmation! if user.respond_to?(:confirmed?)
        user
      end
    end

    factory :confirmed_user, traits: [:confirmed]
  end
end

