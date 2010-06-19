require File.dirname(__FILE__) + '/../../spec_helper'

describe OmniAuth::Strategies::Campfire, :type => :strategy do
  
  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Strategies::Campfire, 'abc', 'def'
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, [Rack::Request.new(env).params.key?('auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end
  
  describe '/auth/campfire without a subdomain' do
    before do
      get '/auth/campfire'
    end
    
    it 'should respond with OK' do
      last_response.should be_ok
    end
    
    it 'should respond with HTML' do
      last_response.content_type.should == 'text/html'
    end
    
    it 'should render a subdomain input' do
      last_response.body.should =~ %r{<input[^>]*subdomain}
    end
  end
  
  describe 'POST /auth/campfire with a subdomain' do
    before do
      # the middleware doesn't actually care that it's a POST,
      # but it makes the "redirect_to" calculation down below easier
      # since the params are passed in the body rather than the URL.
      post '/auth/campfire', {OmniAuth::Strategies::ThirtySevenSignals::SUBDOMAIN_PARAMETER => 'flugle'}
    end
    
    it 'should redirect to the proper authorize_url' do
      last_response.should be_redirect
      redirect_to = CGI.escape(last_request.url + '/callback')
      last_response.headers['Location'].should == "https://flugle.campfirenow.com/oauth/authorize?client_id=abc&redirect_uri=#{redirect_to}&type=web_server"
    end
    
    it 'should set the campfire subdomain in the session' do
      session[:oauth][:campfire][:subdomain].should == 'flugle'
    end
    
  end
  
  describe 'followed by GET /auth/campfire/callback' do
    before do
      stub_request(:post, 'https://flugle.campfirenow.com/oauth/access_token').
         to_return(:body => %q{{"access_token": "your_token"}})
      stub_request(:get, 'https://flugle.campfirenow.com/users/me.json?access_token=your_token').
         to_return(:body => File.read(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'campfire_200.json')))
      get '/auth/campfire/callback?code=plums', {}, {'rack.session' => {:oauth => {:campfire => {:subdomain => 'flugle'}}}}
    end
    
    sets_an_auth_hash
    sets_provider_to 'campfire'
    sets_uid_to '92718'
  
    it 'should exchange the request token for an access token' do
      token = last_request['auth']['extra']['access_token']
      token.should be_kind_of(OAuth2::AccessToken)
      token.token.should == 'your_token'
    end
  
    it 'should call through to the master app' do
      last_response.body.should == 'true'
    end
  end
end
