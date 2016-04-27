require 'spec_helper'

describe Authenticate::Session do
  describe 'session token' do
    it 'finds a user from session token' do
      user = create(:user, :with_session_token)
      request = mock_request
      cookies = cookies_for user
      session = Authenticate::Session.new(request, cookies)
      expect(session.current_user).to eq user
    end
    it 'nil user without a session token' do
      request = mock_request
      cookies = {}
      session = Authenticate::Session.new(request, cookies)
      expect(session.current_user).to be_nil
    end
    it 'returns nil with a bogus session token' do
      request = mock_request
      cookies = { Authenticate.configuration.cookie_name.freeze.to_sym => 'some made up value' }
      session = Authenticate::Session.new(request, cookies)
      expect(session.current_user).to be_nil
    end
  end

  describe '#login' do
    it 'sets current_user' do
      user = create(:user)
      session = Authenticate::Session.new(mock_request, {})
      session.login(user)
      expect(session.current_user).to eq user
    end
    context 'with a block' do
      it 'passes the success status to the block when login succeeds' do
        user = create(:user)
        session = Authenticate::Session.new(mock_request, {})
        session.login(user) do |status|
          expect(status.success?).to eq true
        end
      end
      it 'passes the failure status to the block when login fails' do
        session = Authenticate::Session.new(mock_request, {})
        session.login nil do |status|
          expect(status.success?).to eq false
        end
      end
    end
    context 'with nil argument' do
      it 'assigned current_user to nil' do
        session = Authenticate::Session.new(mock_request, {})
        session.login nil
        expect(session.current_user).to be_nil
      end
    end
    context 'modules' do
      it 'runs the callbacks' do
        user = create(:user, :with_session_token, sign_in_count: 0)
        cookies = { authenticate_session_token: user.session_token }
        session = Authenticate::Session.new(mock_request, cookies)
        expect { session.login(user) }. to change { user.sign_in_count }.by(1)
      end
      it 'fails login if a callback fails' do
        cookies = {}
        session = Authenticate::Session.new(mock_request, cookies)
        session.login nil do |status|
          expect(status.success?).to eq false
          expect(status.message).to eq I18n.t('callbacks.authenticatable.failure')
        end
      end
    end
  end
end

def cookies_for(user)
  { Authenticate.configuration.cookie_name.freeze.to_sym => user.session_token }
end
