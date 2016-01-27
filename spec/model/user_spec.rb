require 'spec_helper'

describe Authenticate::User do

  context 'session tokens' do
    it 'generates a new session token' do
      user = create(:user, :with_session_token)
      old_token = user.session_token
      user.generate_session_token
      expect(user.session_token).to_not eq old_token
    end

    it 'saves user when reset_session_token! called' do
      user = create(:user, :with_session_token)
      old_token = user.session_token
      user.reset_session_token!
      new_user = User.find(user.id)
      expect(new_user.session_token).to_not eq old_token
    end
  end

end