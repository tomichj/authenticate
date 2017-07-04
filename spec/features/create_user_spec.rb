require 'spec_helper'

feature 'create a user with valid attributes' do

  # this doesn't belong as a feature test but it will catch regressions.
  # consider moving to a request spec or... something.
  scenario 'increases number of users' do
    expect { create_user_with_valid_params }.to change { User.count }.by(1)
  end

  scenario 'signs in the user after creation' do
    create_user_with_valid_params
    expect_user_to_be_signed_in
  end

  scenario 'redirects to redirect_url' do
    create_user_with_valid_params
    expect_path_is_redirect_url
  end
end

feature 'visit a protected url, then create user' do
  scenario 'redirects to the protected url after user is created' do
    visit '/welcome'
    create_user_with_valid_params
    expect(current_path).to eq '/welcome'
  end
end

feature 'create user after signed in' do
  scenario 'cannot get to new user page' do
    user = create(:user, email: 'test.user@example.com')
    sign_in_with user.email, user.password
    visit sign_up_path
    expect_path_is_redirect_url
  end
end

def create_user_with_valid_params(user_attrs = attributes_for(:user))
  visit sign_up_path
  fill_in 'user_email', with: user_attrs[:email]
  fill_in 'user_password', with: user_attrs[:password]
  click_button 'Sign up'
end
