require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::Gowalla do
  
  it 'should subclass OAuth2' do
    OmniAuth::Strategies::Gowalla.should < OmniAuth::Strategies::OAuth2
  end
  
  it 'should initialize with just api key and secret key' do
    lambda{OmniAuth::Strategies::Gowalla.new({},'api_key','secret_key')}.should_not raise_error
  end
  
end