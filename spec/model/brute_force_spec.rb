require 'spec_helper'
require 'authenticate/model/brute_force'


describe Authenticate::Model::BruteForce do
  before(:each) do
    @user = create(:user)
  end

  it 'responds to locked?' do
    expect(@user).to respond_to :locked?
  end

  it 'knows when it is locked' do
    expect(@user.locked?).to be_falsey
    @user.lock!
    expect(@user.locked?).to be_truthy
  end

  context '#register_failed_login!' do
    it 'locks when failed login count reaches max' do
      @user.register_failed_login!
      @user.register_failed_login!
      @user.register_failed_login!
      expect(@user.locked?).to be_truthy
    end

    it 'sets lockout period' do
      @user.register_failed_login!
      @user.register_failed_login!
      @user.register_failed_login!
      expect(@user.lock_expires_at).to_not be_nil
    end
  end

  context '#lock!' do
    it 'before lock, locked_expires_at is nil' do
      expect(@user.lock_expires_at).to be_nil
    end

    it 'sets locked_expires_at' do
      @user.lock!
      expect(@user.lock_expires_at).to_not be_nil
      expect(@user.lock_expires_at).to be_utc
    end
  end

  context '#unlock!' do
    before(:each) {
      @user.lock!
      @user.unlock!
    }
    it 'zeros failed_logins_count' do
      expect(@user.failed_logins_count).to be(0)
    end
    it 'nils lock_expires_at' do
      expect(@user.lock_expires_at).to be_nil
    end
  end
end
