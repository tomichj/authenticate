require 'spec_helper'
require 'support/features/feature_helpers'


feature 'visitor updates password' do
  before do
    @user = create(:user, :with_password_reset_token_and_timestamp)
  end

  scenario 'with a valid password' do
    update_password @user, 'newpassword'

    expect_user_to_be_signed_in
  end

  scenario 'with a blank password' do
    update_password @user, ''

    expect(page).to have_content I18n.t('flashes.failure_after_update')
    expect_user_to_be_signed_out
  end

  scenario 'signs in with new password' do
    update_password @user, 'newpassword'

    sign_out
    sign_in_with @user.email, 'newpassword'
    expect_user_to_be_signed_in
  end
end


def update_password(user, password)
  visit_password_reset_page_for user
  fill_in 'password_reset_password', with: password
  click_button 'Save this password'
end

def visit_password_reset_page_for(user)
  visit edit_users_password_path(id: user, token: user.password_reset_token)
end

