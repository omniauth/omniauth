require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::ThirtySevenSignals do
  
  it 'should subclass OAuth2' do
    OmniAuth::Strategies::ThirtySevenSignals.should < OmniAuth::Strategies::OAuth2
  end
  
  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::ThirtySevenSignals.new({},'abc','def')}.should_not raise_error
  end
  
end