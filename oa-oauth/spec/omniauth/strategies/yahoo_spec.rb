require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Yahoo' do
  
  it 'should subclass OAuth' do
    OmniAuth::Strategies::Yahoo.should < OmniAuth::Strategies::OAuth
  end
  
  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::Yahoo.new({},'abc','def')}.should_not raise_error
  end
  
end
