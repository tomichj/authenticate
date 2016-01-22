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

    # trait :with_forgotten_password do
    #   confirmation_token Clearance::Token.new
    # end

    # factory :user_with_optional_password, class: 'UserWithOptionalPassword' do
    #   password nil
    #   encrypted_password ''
    # end
  end
end
