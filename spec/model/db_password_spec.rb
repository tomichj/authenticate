require 'spec_helper'
require 'authenticate/model/db_password'


describe Authenticate::Model::DbPassword do

  it 'validates password' do
    user = build(:user, :without_password)
    user.save
    expect(user.errors.count).to be(1)
    expect(user.errors.messages[:password]).to eq(["can't be blank"])
  end

  it 'matches a password' do
    user = create(:user)
    expect(user.password_match? 'password').to be_truthy
  end

  it 'fails to match a bad password' do
    user = create(:user)
    expect(user.password_match? 'bad password').to be_falsey
  end

  it 'sets a password' do
    user = create(:user)
    user.password = 'new_password'
    user.save!

    user = User.find(user.id)
    expect(user.password_match? 'new_password').to be_truthy
  end

end
