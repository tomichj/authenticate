require 'spec_helper'


describe Authenticate::Session do

  describe 'session token' do
    it 'finds a user from session token' do
      user = create(:user, :with_session_token)
      request = {}
      cookies = {authenticate_session_token: user.session_token}
      session = Authenticate::Session.new(request, cookies)
      expect(session.current_user).to eq user
    end
    it 'returns nil without a session token' do
      request = {}
      cookies = {session_token: nil}
      session = Authenticate::Session.new(request, cookies)
      expect(session.current_user).to be_nil
    end
    it 'returns nil with a bogus session token' do
      request = {}
      cookies = {session_token: 'some made up value'}
      session = Authenticate::Session.new(request, cookies)
      expect(session.current_user).to be_nil
    end
  end

  describe '#login' do
    it 'sets current_user' do
      user = build(:user, :with_session_token)
      session = Authenticate::Session.new(mock_request, {})
      session.login(user)
      expect(session.current_user).to eq user
    end
    context 'with a block' do
      it 'passes the success status to the block when login succeeds' do
        user = build(:user, :with_session_token)
        session = Authenticate::Session.new(mock_request, {})
        session.login user do |status|
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
        cookies = {authenticate_session_token: user.session_token}
        session = Authenticate::Session.new(mock_request, cookies)
        expect{session.login(user)}.to change{user.sign_in_count}.by(1)
      end
      it 'fails login if a callback fails' do
        failure_message = 'THIS IS A FORCED FAIL'
        Authenticate.lifecycle.after_authentication do |user, session, opts|
          throw(:failure, failure_message)
        end
        user = create(:user, :with_session_token, last_access_at: 10.minutes.ago)
        cookies = {authenticate_session_token: user.session_token}
        session = Authenticate::Session.new(mock_request, cookies)
        session.login user do |status|
          expect(status.success?).to eq false
          expect(status.message).to eq failure_message
        end
      end
    end
  end


  def mock_request
    req = double("request")
    allow(req).to receive(:remote_ip).and_return('111.111.111.111')
    return req
  end
end
