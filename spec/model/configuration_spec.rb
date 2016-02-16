require 'spec_helper'
require 'authenticate/configuration'

describe Authenticate::Configuration do

  context 'user model' do
    module Gug
      class Profile
        extend ActiveModel::Naming
      end
    end

    before(:each) do
      Authenticate.configuration = Authenticate::Configuration.new
      Authenticate.configure do |config|
        config.user_model = 'Gug::Profile'
      end
    end

    it 'gets a class for a user model' do
      expect(Authenticate.configuration.user_model_class).to be(Gug::Profile)
    end

    it 'get a route key for a user model' do
      expect(Authenticate.configuration.user_model_route_key).to eq('gug_profiles')
    end

    it 'get a param key for a user model' do
      expect(Authenticate.configuration.user_model_param_key).to eq('gug_profile')
    end

  end



end
