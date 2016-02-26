require 'spec_helper'
require 'support/features/feature_helpers'

feature 'visitor signs in' do
  scenario 'with valid email and password' do
    user = create(:user)
    sign_in_with user.email, user.password
    expect_user_to_be_signed_in
  end

  scenario 'with valid mixed-case email and password' do
    user = create(:user, email: 'test.user@example.com')
    sign_in_with 'Test.USER@example.com', user.password
    expect_user_to_be_signed_in
  end

  scenario 'with invalid password' do
    user = create(:user)
    sign_in_with user.email, 'invalid password'
    expect_page_to_display_sign_in_error
    expect_user_to_be_signed_out
  end

  scenario 'with invalid email' do
    sign_in_with 'unknown@example.com', 'password'
    expect_page_to_display_sign_in_error
    expect_user_to_be_signed_out
  end
end
