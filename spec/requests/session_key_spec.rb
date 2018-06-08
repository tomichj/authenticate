require 'spec_helper'

describe 'session key assignment' do
  context 'user signs in' do
    before do
      @user = create(:user)
      do_post session_path, params: { session: { email: @user.email, password: @user.password } }
    end

    it 'redirects after login' do
      expect(response).to have_http_status(302)
    end

    it 'sets user session token' do
      @user.reload
      expect(@user.session_token).to_not be_nil
    end

    it 'sets session token in cookie' do
      expect(cookies['authenticate_session_token']).to_not be_nil
    end

    it 'sets current_user' do
      expect(controller.current_user).to eq(@user)
    end

    context 'user signs out' do
      it 'rotates user session token' do
        old_session = @user.session_token
        do_get sign_out_path
        @user.reload
        expect(@user.session_token).to_not eq old_session
      end

      it 'removes session cookie' do
        do_get sign_out_path
        expect(cookies['authenticate_session_token']).to eq ''
      end

      it 'sets current_user to nil' do
        do_get sign_out_path
        expect(controller.current_user).to be_nil
      end
    end
  end
end
