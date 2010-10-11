require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Identica' do

  it 'should subclass Identica' do
    OmniAuth::Strategies::Identica.should < OmniAuth::Strategies::OAuth
  end

  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::Identica.new({},'abc','def')}.should_not raise_error
  end

end
