require 'spec_helper'
require 'support/features/feature_helpers'

feature 'visitor signs out' do
  before do
    @user = create(:user)
  end

  scenario 'sign in and sign out' do
    sign_in_with(@user.email, @user.password)
    sign_out
    expect_user_to_be_signed_out
  end

  scenario 'sign out and sign out again' do
    sign_in_with(@user.email, @user.password)
    visit sign_out_path
    visit sign_out_path
    expect_user_to_be_signed_out
  end

end
