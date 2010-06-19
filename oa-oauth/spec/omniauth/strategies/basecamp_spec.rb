require File.dirname(__FILE__) + '/../../spec_helper'

describe OmniAuth::Strategies::Basecamp do
  
  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Strategies::Basecamp, 'abc', 'def'
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, [Rack::Request.new(env).params.key?('auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end
  
  describe '/auth/basecamp without a subdomain' do
    before do
      get '/auth/basecamp'
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
  
  describe 'POST /auth/basecamp with a subdomain' do
    before do
      # the middleware doesn't actually care that it's a POST,
      # but it makes the "redirect_to" calculation down below easier
      # since the params are passed in the body rather than the URL.
      post '/auth/basecamp', {OmniAuth::Strategies::Basecamp::BASECAMP_SUBDOMAIN_PARAMETER => 'flugle'}
    end
    
    it 'should redirect to the proper authorize_url' do
      last_response.should be_redirect
      redirect_to = CGI.escape(last_request.url + '/callback')
      last_response.headers['Location'].should == "https://flugle.basecamphq.com/oauth/authorize?client_id=abc&redirect_uri=#{redirect_to}&type=web_server"
    end
    
    it 'should set the basecamp subdomain in the session' do
      session[:oauth][:basecamp][:subdomain].should == 'flugle'
    end
    
  end
  
  describe 'followed by GET /auth/basecamp/callback' do
    before do
      stub_request(:post, 'https://flugle.basecamphq.com/oauth/access_token').
         to_return(:body => %q{{"access_token": "your_token"}})
      stub_request(:get, 'https://flugle.basecamphq.com/users/me.xml?access_token=your_token').
         to_return(:body => File.read(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'basecamp_200.xml')))
      get '/auth/basecamp/callback?code=plums', {}, {'rack.session' => {:oauth => {:basecamp => {:subdomain => 'flugle'}}}}
    end
  
    it 'should set the provider to "basecamp"' do
      last_request['auth']['provider'].should == 'basecamp'
    end
  
    it 'should set the UID to "1827370"' do
      last_request['auth']['uid'].should == '1827370'
    end
  
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
