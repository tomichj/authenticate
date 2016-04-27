require 'spec_helper'
require 'support/features/feature_helpers'

feature 'visitor has consecutive bad logins' do
  before(:each) do
    @user = create(:user)
  end

  scenario 'visitor logs in and subsequent click within lifetime' do
    sign_in_with @user.email, @user.password
    expect_user_to_be_signed_in

    Timecop.travel 10.minutes do
      visit root_path
      expect_user_to_be_signed_in
    end
  end

  scenario 'visitor logs in and lets session live too long' do
    sign_in_with @user.email, @user.password
    expect_user_to_be_signed_in

    Timecop.travel 21.minutes do
      visit root_path
      expect(current_path).to eq sign_in_path
      expect_user_to_be_signed_out
    end
  end
end
