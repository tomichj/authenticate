require 'spec_helper'

feature 'visitor signs out' do
  before do
    @user = create(:user)
  end

  scenario 'sign in and sign out' do
    sign_in_with(@user.email, @user.password)
    sign_out
    expect_user_to_be_signed_out
  end

  scenario 'sign out again' do
    sign_in_with(@user.email, @user.password)
    visit sign_out_path
    visit sign_out_path
    expect_user_to_be_signed_out
  end

  scenario 'redirects to sign in' do
    sign_in_with(@user.email, @user.password)
    visit sign_out_path
    expect_sign_in_path
  end
end


def expect_sign_in_path
  expect(current_path).to eq sign_in_path
end
