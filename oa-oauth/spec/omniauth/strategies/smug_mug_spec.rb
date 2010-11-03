require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::SmugMug do
  
  it 'should subclass OAuth' do
    OmniAuth::Strategies::SmugMug.should < OmniAuth::Strategies::OAuth
  end
  
  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::SmugMug.new({},'abc','def')}.should_not raise_error
  end

end