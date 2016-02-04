require 'spec_helper'
require 'authenticate/model/email'


describe Authenticate::Model::Email do

  it 'validates email' do
    user = build(:user, :without_email)
    user.save
    expect(user.errors.count).to be(2)
    expect(user.errors.messages[:email]).to include('is invalid')
    expect(user.errors.messages[:email]).to include("can't be blank")
  end

  it 'extracts credentials from params' do
    params = {session:{email:'foo', password:'bar'}}
    expect(User.credentials(params)).to match_array(['foo', 'bar'])
  end

  it 'authenticates from credentials' do
    user = create(:user)
    expect(User.authenticate([user.email, user.password])).to eq(user)
  end

end
