require 'spec_helper'

feature 'visitor session time' do
  before do
    @user = create(:user)
    Authenticate.configuration.timeout_in = 10.minutes
  end

  scenario 'visitor logs in, subsequent click within timeout' do
    sign_in_with @user.email, @user.password
    expect_user_to_be_signed_in

    Timecop.travel 5.minutes do
      visit root_path
      expect_user_to_be_signed_in
    end
  end

  scenario 'visitor logs in, subsequent click after session times out' do
    sign_in_with @user.email, @user.password
    expect_user_to_be_signed_in

    Timecop.travel 11.minutes do
      visit root_path
      expect(current_path).to eq sign_in_path
      expect_user_to_be_signed_out
    end
  end
end
