require 'spec_helper'
require 'support/features/feature_helpers'

feature 'visitor requests password reset' do
  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  scenario 'navigates to Forgot Password page' do
    visit sign_in_path
    click_link 'Forgot Password'
    expect(current_path).to eq new_password_path
  end

  scenario 'uses valid email' do
    user = create(:user)
    request_password_reset_for user.email

    expect_password_change_request_success_message
    expect_user_to_have_password_reset_attributes user
    expect_password_reset_email_for user
  end

  scenario 'with a non-user-account email' do
    request_password_reset_for 'fake.email@example.com'

    expect_password_change_request_success_message
    expect_mailer_to_have_no_deliveries
  end

  scenario 'with invalid email' do
    request_password_reset_for 'not_an_email_address'

    expect_password_change_request_success_message
    expect_mailer_to_have_no_deliveries
  end
end


def request_password_reset_for email
  visit new_password_path
  fill_in 'password_email', with: email
  click_button 'Reset password'
end

def expect_password_change_request_success_message
  expect(page).to have_content I18n.t('passwords.create.description')
end

def expect_user_to_have_password_reset_attributes user
  user.reload
  expect(user.password_reset_token).not_to be_blank
  expect(user.password_reset_sent_at).not_to be_blank
end

def expect_password_reset_email_for user
  recipient = user.email
  token = user.password_reset_token
  expect(ActionMailer::Base.deliveries).not_to be_empty
  ActionMailer::Base.deliveries.any? do |email|
    email.to == [recipient] &&
        email.html_part.body =~ /#{token}/ &&
        email.text_part.body =~ /#{token}/
  end
end

def expect_mailer_to_have_no_deliveries
  expect(ActionMailer::Base.deliveries).to be_empty
end
