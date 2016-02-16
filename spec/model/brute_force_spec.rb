require 'spec_helper'
require 'authenticate/model/brute_force'


describe Authenticate::Model::BruteForce do
  before(:all) do
    Authenticate.configuration = Authenticate::Configuration.new
    Authenticate.configure do |config|
      config.max_consecutive_bad_logins_allowed = 2
      config.bad_login_lockout_period = 2.minutes
    end
  end

  it 'knows when it is locked' do
    user = User.new
    expect(user.locked?).to be_falsey
    user.lock!
    expect(user.locked?).to be_truthy
  end

  context '#register_failed_login!' do
    it 'locks when failed login count reaches max' do
      user = User.new
      user.register_failed_login!
      user.register_failed_login!
      expect(user.locked?).to be_truthy
    end

    it 'sets lockout period' do
      user = User.new
      user.register_failed_login!
      user.register_failed_login!
      expect(user.lock_expires_at).to_not be_nil
    end
  end

  context '#lock!' do
    it 'before lock, locked_expires_at is nil' do
      user = User.new
      expect(user.lock_expires_at).to be_nil
    end

    it 'sets locked_expires_at' do
      user = User.new
      user.lock!
      expect(user.lock_expires_at).to_not be_nil
      expect(user.lock_expires_at).to be_utc
    end
  end

  context '#unlock!' do
    let(:user) { User.new }
    before(:each) {
      user.lock!
      user.unlock!
    }
    it 'zeros failed_logins_count' do
      expect(user.failed_logins_count).to be(0)
    end
    it 'nils lock_expires_at' do
      expect(user.lock_expires_at).to be_nil
    end
  end
end
