require File.expand_path('../../../spec_helper', __FILE__)

describe 'OmniAuth::Strategies::LastFm' do
  it 'should initialize with a consumer key and secret' do
    lambda{OmniAuth::Strategies::LastFm.new({},'abc','def')}.should_not raise_error
  end
end
