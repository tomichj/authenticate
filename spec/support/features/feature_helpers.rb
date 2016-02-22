module Features
  module FeatureHelpers


    def sign_in_with(email, password)
      visit sign_in_path
      fill_in 'session_email', with: email
      fill_in 'session_password', with: password
      click_button 'Sign in'
    end

    def sign_out
      within '#header' do
        click_link I18n.t("layouts.application.sign_out")
      end
    end

    def expect_user_to_be_signed_in
      visit root_path
      expect(page).to have_link 'Sign out'
    end

    def expect_page_to_display_sign_in_error
      expect(page).to have_content 'Invalid id or password'
    end

    def expect_user_to_be_signed_out
      expect(page).to have_content 'Sign in'
    end

  end
end

RSpec.configure do |config|
  config.include Features::FeatureHelpers, type: :feature
end
