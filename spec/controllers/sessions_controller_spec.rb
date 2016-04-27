require 'spec_helper'
require 'support/controllers/controller_helpers'

describe Authenticate::SessionsController, type: :controller do
  it { is_expected.to be_a Authenticate::Controller }

  describe 'get to #new' do
    context 'when user not signed in' do
      before do
        get :new
      end
      it { is_expected.to respond_with 200 }
      it { is_expected.to render_template :new }
      it { is_expected.not_to set_flash }
    end

    context 'when user is signed in' do
      before do
        sign_in
        get :new
      end

      it { is_expected.not_to set_flash }
      it { is_expected.to redirect_to(Authenticate.configuration.redirect_url) }
    end
  end

  describe 'post to #create' do
    context 'without password' do
      it 'renders page with error' do
        user = create(:user)
        post :create, session: { email: user.email }
        expect(response).to render_template :new
        expect(flash[:notice]).to match(/Invalid id or password/)
      end
    end
    context 'with good password' do
      before do
        @user = create(:user)
        post :create, session: { email: @user.email, password: @user.password }
      end
      it { is_expected.to respond_with 302 }

      it { is_expected.to redirect_to Authenticate.configuration.redirect_url }

      it 'sets user session token' do
        @user.reload
        expect(@user.session_token).to_not be_nil
      end

      it 'sets user session' do
        expect(controller.current_user).to eq(@user)
      end
    end
  end

  describe 'delete to #destroy' do
    context 'with a signed out user' do
      before do
        sign_out
        get :destroy
      end

      it { is_expected.to redirect_to sign_in_url }
    end

    context 'with a session cookie' do
      before do
        @user = create(:user, session_token: 'old-session-token')
        @request.cookies['authenticate_session_token'] = 'old-session-token'
        get :destroy
      end

      it { is_expected.to redirect_to sign_in_url }

      it 'reset the session token' do
        @user.reload
        expect(@user.session_token).to_not eq('old-session-token')
      end

      it 'unset the current user' do
        expect(controller.current_user).to be_nil
      end
    end
  end
end
