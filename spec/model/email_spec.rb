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
    params = { session: { email: 'foo', password: 'bar' } }
    expect(User.credentials(params)).to match_array(%w(foo bar))
  end

  it 'authenticates from credentials' do
    user = create(:user)
    expect(User.authenticate([user.email, user.password])).to eq(user)
  end

  it 'validates unique email address' do
    original = build(:user, email: 'email@email.com')
    dupe_email = build(:user, email: 'email@email.com')

    original.save
    dupe_email.save

    expect(dupe_email.errors.count).to be(1)
    expect(dupe_email.errors.messages[:email]).to include('has already been taken')
  end
end
