require 'spec_helper'
require 'authenticate/model/password_reset'


describe Authenticate::Model::PasswordReset do
  before(:all) {
    Authenticate.configuration = Authenticate::Configuration.new
    Authenticate.configuration.reset_password_within = 5.minutes
  }
  context 'forgot_password!' do
    subject { create(:user) }
    before { subject.forgot_password! }

    it 'generates a password reset token' do
      expect(subject.password_reset_token).to_not be_nil
    end

    it 'sets password reset sent at' do
      expect(subject.password_reset_sent_at).to_not be_nil
    end

  end

  context '#reset_password_period_valid?' do
    subject { create(:user) }
    before(:each) {
      Authenticate.configuration.reset_password_within = 5.minutes
    }

    it 'always true if reset_password_within config param is nil' do
      subject.password_reset_sent_at = 10.days.ago
      Authenticate.configuration.reset_password_within = nil
      expect(subject.reset_password_period_valid?).to be_truthy
    end

    it 'false if time exceeded' do
      subject.password_reset_sent_at = 10.minutes.ago
      expect(subject.reset_password_period_valid?).to be_falsey
    end

    it 'true if time within limit' do
      subject.password_reset_sent_at = 1.minutes.ago
      expect(subject.reset_password_period_valid?).to be_truthy
    end
  end

  context '#update_password' do
    subject { create(:user) }
    before(:each) {
      Authenticate.configuration.reset_password_within = 5.minutes
    }

    context 'within time time' do
      before(:each) {
        subject.password_reset_sent_at = 1.minutes.ago
      }

      it 'allows password update within time limit' do
        expect(subject.update_password 'password2').to be_truthy
      end

      it 'clears password reset token' do
        subject.update_password 'password2'
        expect(subject.password_reset_token).to be_nil
      end

      it 'generates a new session token' do
        token = subject.session_token
        subject.update_password 'password2'
        expect(subject.session_token).to_not eq(token)
      end

    end

    it 'stops password update after time limit' do
      subject.password_reset_sent_at = 6.minutes.ago
      expect(subject.update_password 'password2').to be_falsey
    end

  end

end
