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

def request_password_reset_for(email)
  visit new_password_path
  fill_in 'password_email', with: email
  click_button 'Reset password'
end

def expect_password_change_request_success_message
  expect(page).to have_content I18n.t('passwords.create.description')
end

def expect_user_to_have_password_reset_attributes(user)
  user.reload
  expect(user.password_reset_token).not_to be_blank
  expect(user.password_reset_sent_at).not_to be_blank
end

def expect_password_reset_email_for(user)
  expect(ActionMailer::Base.deliveries).not_to be_empty
  ActionMailer::Base.deliveries.any? do |email|
    email.to == [user.email] &&
      email.html_part.body =~ /#{user.password_reset_token}/ &&
      email.text_part.body =~ /#{user.password_reset_token}/
  end
end

def expect_mailer_to_have_no_deliveries
  expect(ActionMailer::Base.deliveries).to be_empty
end

feature 'visitor sets new password' do
  scenario 'requests password change' do
    user = given_user_with_password_reset_token
    visit_password_update_page_for user
    request_password_change
    expect_password_is_changed_for user
    expect_redirect_to_root
  end

  scenario 'attempts password change with fake password reset token' do
    user = given_user_with_fake_password_reset_token
    visit_password_update_page_for user
    expect_failure_flash
  end
end

def given_user_with_fake_password_reset_token
  user = create :user
  user.password_reset_token = 'big_fake_token'
  user
end

def given_user_with_password_reset_token
  create :user, :with_password_reset_token_and_timestamp
end

def visit_password_update_page_for(user)
  visit edit_users_password_path(user.id, token: user.password_reset_token)
end

def request_password_change
  fill_in 'password_reset_password', with: 'new_dumb_password'
  click_button 'Save this password'
end

def expect_password_is_changed_for(user)
  old_encrypted_password = user.encrypted_password
  expect(user.reload.encrypted_password).to_not eq old_encrypted_password
end

def expect_redirect_to_root
  expect(current_path).to eq Authenticate.configuration.redirect_url
end

def expect_failure_flash
  expect(page).to have_content 'Please double check the URL or try submitting the form again.'
end
