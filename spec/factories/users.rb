FactoryBot.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  factory :user do
    email
    password 'password'

    trait :without_email do
      email nil
    end

    trait :without_password do
      password nil
      encrypted_password nil
    end

    trait :with_session_token do
      session_token 'this_is_a_big_fake_long_token'
    end

    trait :with_password_reset_token_and_timestamp do
      password_reset_token Authenticate::Token.new
      password_reset_sent_at 10.seconds.ago
    end
  end
end
