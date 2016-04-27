require 'spec_helper'
require 'authenticate/model/lifetimed'

describe Authenticate::Model::Lifetimed do
  context '#max_session_lifetime_exceeded?' do
    it 'passes fresh sessions' do
      Timecop.freeze do
        user = create(:user, current_sign_in_at: 1.minute.ago.utc)
        expect(user).to_not be_max_session_lifetime_exceeded
      end
    end

    it 'detects timed out sessions' do
      Timecop.freeze do
        user = create(:user, current_sign_in_at: 5.hours.ago.utc)
        expect(user).to be_max_session_lifetime_exceeded
      end
    end
  end
end
