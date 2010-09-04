require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::TypePad' do
  
  it 'should subclass OAuth' do
    OmniAuth::Strategies::TypePad.should < OmniAuth::Strategies::OAuth
  end
  
  it 'should initialize with consumer key, secret, and application ID' do
    lambda{OmniAuth::Strategies::TypePad.new({},'abc','def', 'ghi')}.should_not raise_error
  end
  
end
