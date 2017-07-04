require 'spec_helper'

feature 'visitor signs up' do
  scenario 'navigates to sign up page' do
    visit sign_in_path
    click_link 'Sign Up'
    expect_sign_up_page
  end

  scenario 'signs up with valid email and password' do
    sign_up_with 'valid@example.com', 'password'
    expect_user_to_be_signed_in
  end

  scenario 'signs up with invalid email' do
    sign_up_with 'bad_email', 'password'
    expect_user_to_be_signed_out
  end

  scenario 'signs up with invalid short password' do
    sign_up_with 'bad_email', '111'
    expect_user_to_be_signed_out
  end

  scenario 'signs up with blank password' do
    sign_up_with 'bad_email', ''
    expect_user_to_be_signed_out
  end
end

def expect_sign_up_page
  expect(current_path).to eq sign_up_path
end

def sign_up_with(email, password)
  visit sign_up_path
  fill_in 'user_email', with: email
  fill_in 'user_password', with: password
  click_button 'Sign up'
end
