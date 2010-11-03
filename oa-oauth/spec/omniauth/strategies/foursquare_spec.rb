require 'spec_helper'

describe OmniAuth::Strategies::Foursquare do
  context 'changing authentication path' do
    subject{ OmniAuth::Strategies::Foursquare.new app, 'key', 'secret', (@options || {})}
    
    [
      ['/oauth/authenticate',{}],
      ['/oauth/authorize',{:sign_in => false}],
      ['/mobile/oauth/authenticate', {:mobile => true}],
      ['/mobile/oauth/authorize', {:mobile => true, :sign_in => false}]
    ].each do |(path, opts)|
      it "should be #{path} with options #{opts.inspect}" do
        @options = opts
        subject.consumer.options[:authorize_path].should == path
      end
    end
  end
end