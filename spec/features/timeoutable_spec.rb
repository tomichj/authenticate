require 'spec_helper'
require 'support/features/feature_helpers'

feature 'visitor session time' do
  before do
    Authenticate.configure do |config|
      config.timeout_in = 20.minutes
      config.max_session_lifetime = nil
    end
    @user = create(:user)
  end

  scenario 'visitor logs in, subsequent click within timeout' do
    sign_in_with @user.email, @user.password
    expect_user_to_be_signed_in

    Timecop.travel 10.minutes do
      visit root_path
      expect_user_to_be_signed_in
    end
  end

  scenario 'visitor logs in, subsequent click after session times out' do
    sign_in_with @user.email, @user.password
    expect_user_to_be_signed_in

    Timecop.travel 21.minutes do
      visit root_path
      expect(current_path).to eq sign_in_path
      expect_user_to_be_signed_out
    end
  end

end
