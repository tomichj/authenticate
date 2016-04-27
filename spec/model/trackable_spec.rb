require 'spec_helper'
require 'authenticate/model/trackable'

describe Authenticate::Model::Trackable do
  subject { create(:user) }
  context '#last_sign_in_at' do
    it 'sets to old current_sign_in_at if it is not nil' do
      old_sign_in = 2.days.ago.utc
      subject.current_sign_in_at = old_sign_in
      subject.update_tracked_fields mock_request
      expect(subject.last_sign_in_at).to eq(old_sign_in)
    end

    it 'sets to current time if old current_sign_in_at is nil' do
      subject.current_sign_in_at = nil
      subject.update_tracked_fields mock_request
      expect(subject.last_sign_in_at).to be_within(5.seconds).of(Time.now.utc)
    end
  end

  context '#last_sign_in_ip' do
    it 'sets to old current_sign_in_ip if it is not nil' do
      old_ip = '222.222.222.222'
      subject.current_sign_in_ip = old_ip
      subject.update_tracked_fields mock_request
      expect(subject.last_sign_in_ip).to eq(old_ip)
    end

    it 'sets to current ip if old current_sign_in_ip is nil' do
      subject.current_sign_in_ip = nil
      subject.update_tracked_fields mock_request
      expect(subject.last_sign_in_ip).to_not be_nil
    end
  end

  it 'sets current_sign_in_at to now' do
    subject.current_sign_in_at = nil
    subject.update_tracked_fields mock_request
    expect(subject.current_sign_in_at).to be_within(5.seconds).of(Time.now.utc)
  end

  context '#sign_in_count' do
    it 'initializes a nil count' do
      subject.sign_in_count = nil
      subject.update_tracked_fields mock_request
      expect(subject.sign_in_count).to eq(1)
    end
    it 'increments existing count' do
      subject.sign_in_count = 4
      subject.update_tracked_fields mock_request
      expect(subject.sign_in_count).to eq(5)
    end
  end
end
