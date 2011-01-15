require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Flickr' do
  it 'should initialize with a consumer key and secret' do
    lambda{OmniAuth::Strategies::Flickr.new({},'abc','def')}.should_not raise_error
  end
end
