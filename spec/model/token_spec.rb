require 'spec_helper'

describe Authenticate::Token do
  it 'is a random hex string' do
    token = 'my_token'
    allow(SecureRandom).to receive(:hex).with(20).and_return(token)
    expect(Authenticate::Token.new).to eq token
  end
end
