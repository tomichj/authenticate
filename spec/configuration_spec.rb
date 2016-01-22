require 'spec_helper'

describe Authenticate::Configuration do
  after {restore_default_configuration}

  context 'when no user_model_name is specified' do
    before do
      Authenticate.configure do |config|
      end
    end

    it 'defaults to User' do
      expect(Authenticate.configuration.user_model).to eq '::User'
      expect(Authenticate.configuration.user_model_class).to eq ::User
    end
  end

  context 'with a customer user_model' do
    before do
      MyUser = Class.new
      Authenticate.configure do |config|
        config.user_model = 'MyUser'
      end
    end

    it 'is used instead of User' do
      expect(Authenticate.configuration.user_model_class).to eq MyUser
    end
  end

  describe '#authentication_strategy' do
    context 'with no strategy set' do
      it 'defaults to email' do
        expect(Authenticate.configuration.authentication_strategy).to eq :email
      end
      it 'includes email in modules' do
        expect(Authenticate.configuration.modules).to include :email
      end
      it 'does not include username in modules' do
        expect(Authenticate.configuration.modules).to_not include :username
      end
    end

    context 'with strategy set to username' do
      before do
        Authenticate.configure do |config|
          config.authentication_strategy = :username
        end
      end
      it 'includes username in modules' do
        expect(Authenticate.configuration.modules).to include :username
      end
      it 'does not include email in modules' do
        expect(Authenticate.configuration.modules).to_not include :email
      end
    end

  end

end
