require 'authenticate/user'

FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email
    encrypted_password 'password'

    trait :with_session_token do
      session_token 'this_is_a_big_fake_long_token'
    end

    trait :with_forgotten_password do
      password_reset_token Authenticate::Token.new
    end
  end
end
