require 'spec_helper'
require 'authenticate/model/db_password'


describe Authenticate::Model::DbPassword do
  describe 'Passwords' do

    context '#password_match?' do
      subject { create(:user, password: 'password') }

      it 'matches a password' do
        expect(subject.password_match? 'password').to be_truthy
      end

      it 'fails to match a bad password' do
        expect(subject.password_match? 'bad password').to be_falsey
      end

      it 'saves passwords' do
        subject.password = 'new_password'
        subject.save!

        user = User.find(subject.id)
        expect(user.password_match? 'new_password').to be_truthy
      end
    end

    describe 'Validations' do
      before(:all) {
        Authenticate.configure do |config|
          config.password_length = 8..128
        end
      }

      context 'on a new user' do
        it 'should not be valid without a password' do
          user = build(:user, :without_password)
          expect(user).to_not be_valid
        end

        it 'should be not be valid with a short password' do
          user = build(:user, password: 'short')
          expect(user).to_not be_valid
        end

        it 'is valid with a long password' do
          user = build(:user, password: 'thisisalongpassword')
          expect(user).to be_valid
        end
      end

      context 'on an existing user' do
        subject { create(:user, password: 'password') }

        it { is_expected.to be_valid  }

        it 'should not be valid with an empty password' do
          subject.password = ''
          expect(subject).to_not be_valid
        end

        it 'should be valid with a new (valid) password' do
          subject.password = 'new password'
          expect(subject).to be_valid
        end
      end
    end

  end
end
