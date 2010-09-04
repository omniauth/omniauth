require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Google' do
  
  it 'should subclass OAuth' do
    OmniAuth::Strategies::Google.should < OmniAuth::Strategies::OAuth
  end
  
  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::Google.new({},'abc','def')}.should_not raise_error
  end
  
end
