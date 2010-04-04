require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class Rack::Session::Phony
  def initialize(app); @app = app end
  def call(env)
    env['rack.session'] ||= {}
    @app.call(env)
  end
end

def app
  Rack::Builder.new {
    use Rack::Session::Phony
    use OmniAuth::Builder do
      provider :oauth, :twitter, 'abc', 'def', :site => 'https://api.twitter.com'
      provider :oauth, :linked_in, 'abc', 'def', :site => 'https://api.linkedin.com'
    end
    run lambda { |env| [200, {'Content-Type' => 'text/plain'}, Rack::Request.new(env).params.key?('auth').to_s] }
  }.to_app
end

def session
  last_request.env['rack.session']
end

describe "OmniAuth::Strategies::OAuth" do
  before do
    stub_request(:post, 'https://api.twitter.com/oauth/request_token').
      to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret&oauth_callback_confirmed=true")
    stub_request(:post, 'https://api.twitter.com/oauth/access_token').
      to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret")
  end
  
  describe '/auth/{name}' do
    before do
      get '/auth/twitter'
    end
    it 'should redirect to authorize_url' do
      last_response.should be_redirect
      last_response.headers['Location'].should == 'https://api.twitter.com/oauth/authorize?oauth_token=yourtoken'
    end
  
    it 'should set appropriate session variables' do
      session[:oauth].should == {:twitter => {:callback_confirmed => true, :request_token => 'yourtoken', :request_secret => 'yoursecret'}}
    end
  end
  
  describe '/auth/{name}/callback' do
    before do
      get '/auth/twitter/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {:oauth => {:twitter => {:callback_confirmed => true, :request_token => 'yourtoken', :request_secret => 'yoursecret'}}}}
    end
    
    it 'should exchange the request token for an access token' do
      last_request['auth']['provider'].should == 'twitter'
      last_request['auth']['extra']['access_token'].should be_kind_of(OAuth::AccessToken)
    end
    
    it 'should call through to the master app' do
      last_response.body.should == 'true'
    end
  end
end

describe 'OmniAuth::Strategies::Twitter' do
  it 'should subclass OAuth' do
    OmniAuth::Strategies::Twitter.should < OmniAuth::Strategies::OAuth
  end
  
  it 'should initialize with just consumer key and secret' do
    OmniAuth::Strategies::Twitter.new({},'abc','def')
  end
end