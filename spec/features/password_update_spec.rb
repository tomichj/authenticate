require 'spec_helper'
require 'support/features/feature_helpers'


feature 'visit password edit screen' do
  scenario 'with valid token in url, redirects to the edit page with the token removed from the url' do
    user = create(:user, :with_password_reset_token_and_timestamp)
    visit_password_reset_page_for(user)
    expect(current_path).to  eq edit_users_password_path(user)
    expect(current_path).to_not have_content('token')
  end

  scenario 'with an invalid token in url, failure and prompt to request a password reset' do
    user = create(:user, :with_password_reset_token_and_timestamp)
    visit_password_reset_page_for(user, 'this is an invalid token')
    expect_forbidden_failure
  end

  scenario 'with a valid token, but an expired timestamp' do
    user = create(:user, :with_password_reset_token_and_timestamp, password_reset_sent_at: 20.years.ago)
    visit_password_reset_page_for(user)
    expect_token_expired_failure
  end

  scenario 'with a nil token' do
    user = create(:user)
    visit_password_reset_page_for(user, token: nil)
    expect_forbidden_failure
  end
end


feature 'visitor updates password' do
  before(:each) do
    @user = create(:user, :with_password_reset_token_and_timestamp)
  end

  scenario 'with valid password, signs in user' do
    update_password @user, 'newpassword'
    expect_user_to_be_signed_in
  end

  scenario 'with a valid password, password is updated' do
    old_pw = @user.encrypted_password
    update_password @user, 'newpassword'
    expect_password_was_updated(old_pw)
  end

  scenario 'password change signs in user' do
    update_password @user, 'newpassword'
    sign_out
    sign_in_with @user.email, 'newpassword'
    expect_user_to_be_signed_in
  end

  scenario 'signs in, redirects user' do
    update_password @user, 'newpassword'
    expect_path_is_redirect_url
  end
end

feature 'visitor updates password with invalid password' do
  before(:each) do
    @user = create(:user, :with_password_reset_token_and_timestamp)
  end

  scenario 'with a blank password, signs out user' do
    update_password @user, ''
    expect_invalid_password
    expect_user_to_be_signed_out
  end

  scenario 'with a short password, flashes invalid password' do
    update_password @user, 'short'
    expect_invalid_password
    expect_user_to_be_signed_out
  end
end


def update_password(user, password)
  visit_password_reset_page_for user
  fill_in 'password_reset_password', with: password
  click_button 'Save this password'
end

def visit_password_reset_page_for(user, token = user.password_reset_token)
  visit edit_users_password_path(id: user, token: token)
end

def expect_invalid_password
  expect(page).to have_content I18n.t('flashes.failure_after_update')
end

def expect_forbidden_failure
  expect(page).to have_content I18n.t('passwords.new.description')
  expect(page).to have_content I18n.t('flashes.failure_when_forbidden')
end

def expect_token_expired_failure
  expect(page).to have_content 'Sign in'
  expect(page).to have_content I18n.t('flashes.failure_token_expired')
end

# def expect_path_is_redirect_url
#   expect(current_path).to eq(Authenticate.configuration.redirect_url)
# end

def expect_password_was_updated(old_password)
  expect(@user.reload.encrypted_password).not_to eq old_password
end
