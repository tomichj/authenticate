require 'spec_helper'

describe 'CSRF rotation' do
  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
    ActionController::Base.allow_forgery_protection = false
  end

  context 'Authenticate configuration is set to rotate CSRF token on sign in' do
    describe 'sign in' do
      before do
        @user = create(:user, password: 'password')
      end
      it 'rotates the CSRF token' do
        Authenticate.configure { |config| config.rotate_csrf_on_sign_in = true }

        # go to sign in screen, generating csrf
        get sign_in_path
        original_token = csrf_token

        # post a login
        do_post session_path, params: { **session_params }

        # expect that we now have a new csrf token
        expect(response).to have_http_status(302)
        expect(csrf_token).not_to eq original_token
        expect(csrf_token).to be_present
      end
    end
  end

  def csrf_token
    session[:_csrf_token]
  end

  def session_params
    { session: { email: @user.email, password: @user.password }, authenticity_token: csrf_token  }
  end
end
