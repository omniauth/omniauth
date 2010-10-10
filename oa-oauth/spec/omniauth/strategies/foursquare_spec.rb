require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'OmniAuth::Strategies::Foursquare' do
  
  it 'should subclass OAuth' do
    OmniAuth::Strategies::Foursquare.should < OmniAuth::Strategies::OAuth
  end
  
  it 'should initialize with just consumer key and secret' do
    lambda{OmniAuth::Strategies::Foursquare.new({},'abc','def')}.should_not raise_error
  end
  
  let(:foursquare) { OmniAuth::Strategies::Foursquare.new({},'abc','def') }
  
  it "should use the authenticate endpoint" do
    foursquare.consumer.authorize_path.should == '/oauth/authenticate'
    foursquare.consumer.authorize_url.should == 'http://foursquare.com/oauth/authenticate'
  end
  
  context "mobile version" do
    let(:foursquare) { OmniAuth::Strategies::Foursquare.new({},'abc','def', :mobile => true) }
    
    it "should use the mobile authenticate endpoint" do
      foursquare.consumer.authorize_path.should == '/mobile/oauth/authenticate'
      foursquare.consumer.authorize_url.should == 'http://foursquare.com/mobile/oauth/authenticate'
    end
  end
end