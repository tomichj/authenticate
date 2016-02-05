require 'spec_helper'
require 'authenticate/model/lifetimed'


describe Authenticate::Model::Lifetimed do

  context '#max_session_timedout?' do
    before {
      Authenticate.configure do |config|
        config.max_session_lifetime = 10.minutes
      end
    }

    it 'passes fresh sessions' do
      user = create(:user, current_sign_in_at: 1.minute.ago.utc)
      expect(user).to_not be_max_session_timedout
    end

    it 'detects timed out sessions' do
      user = create(:user, current_sign_in_at: 5.hours.ago.utc)
      expect(user).to be_max_session_timedout
    end

    describe 'max_session_lifetime param not set' do
      it 'does not time out' do
        user = create(:user, current_sign_in_at: 5.hours.ago.utc)
        Authenticate.configure do |config|
          config.max_session_lifetime = nil
        end
        expect(user).to_not be_max_session_timedout
      end
    end
  end

end
