require 'spec_helper'
require 'authenticate/model/timeoutable'


describe Authenticate::Model::Timeoutable do
  subject { create(:user) }

  it 'does not timeout while last_access_at is valid' do
    Timecop.freeze do
      subject.last_access_at = 10.minutes.ago
      expect(subject.timedout?).to be_falsey
    end
  end

  it 'does timeout when last_access_at is stale' do
    Timecop.freeze do
      subject.last_access_at = 46.minutes.ago
      expect(subject.timedout?).to be_truthy
    end
  end
end
