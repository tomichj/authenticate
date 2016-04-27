require 'spec_helper'

describe Authenticate::Modules do
  # dummy user model to test .check_fields
  class UserProfile
    extend ActiveModel::Model
    include Authenticate::Modules
  end

  describe '.check_fields' do
    context 'user model with missing fields' do
      it 'fails when required_fields are not present' do
        expect { UserProfile.load_modules }.to raise_error(Authenticate::Modules::MissingAttribute)
      end
    end
    context 'user model with all fields' do
      it 'fleshed out user model is fine' do
        expect { User.load_modules }.to_not raise_error
      end
    end
  end
end
