require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Dopplr' do

  it 'should subclass OAuth' do
    OmniAuth::Strategies::Dopplr.should < OmniAuth::Strategies::OAuth
  end

  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::Dopplr.new({},'abc','def')}.should_not raise_error
  end

end
