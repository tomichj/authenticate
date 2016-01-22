require 'spec_helper'

describe Authenticate::User do

  it 'generates a new session token' do
    user = create(:user, :with_session_token)
    old_token = user.session_token
    user.generate_session_token
    expect(user.session_token).to_not eq old_token
  end

end