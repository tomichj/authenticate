require 'spec_helper'
require 'authenticate/configuration'

describe Authenticate::Configuration do
  context 'user model' do
    module Gug
      # Faux user model
      class Profile
        extend ActiveModel::Naming
      end
    end

    before(:each) do
      @conf = Authenticate::Configuration.new
      @conf.user_model = 'Gug::Profile'
    end

    it 'gets a class for a user model' do
      expect(@conf.user_model_class).to be(Gug::Profile)
    end

    it 'get a route key for a user model' do
      expect(@conf.user_model_route_key).to eq('gug_profiles')
    end

    it 'get a param key for a user model' do
      expect(@conf.user_model_param_key).to eq(:gug_profile)
    end

    describe '#authentication_strategy' do
      context 'with no strategy set' do
        it 'defaults to email' do
          expect(@conf.authentication_strategy).to eq :email
        end
        it 'includes email in modules' do
          expect(@conf.modules).to include :email
        end
        it 'does not include username in modules' do
          expect(@conf.modules).to_not include :username
        end
      end

      context 'with strategy set to username' do
        before do
          @conf.authentication_strategy = :username
        end
        it 'includes username in modules' do
          expect(@conf.modules).to include :username
        end
        it 'does not include email in modules' do
          expect(@conf.modules).to_not include :email
        end
      end
    end
  end
end
