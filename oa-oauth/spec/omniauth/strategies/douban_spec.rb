require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OmniAuth::Strategies::Douban do

  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider :douban, 'abc', 'def'
      end
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end

  before do
    stub_request(:post, 'http://www.douban.com/service/auth/request_token').
       to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret&oauth_callback_confirmed=false")
  end

  describe '/auth/{name}' do
    before do
      get '/auth/douban'
    end
    it 'should redirect to authorize_url' do
      last_response.should be_redirect
      oauth_callback = CGI.escape('http://example.org/auth/douban/callback')
      last_response.headers['Location'].should == "http://www.douban.com/service/auth/authorize?oauth_callback=#{oauth_callback}&oauth_token=yourtoken"
    end

    it 'should set appropriate session variables' do
      session[:oauth].should == {:douban => {:callback_confirmed => false, :request_token => 'yourtoken', :request_secret => 'yoursecret'}}
    end
  end

  it_should_behave_like 'an oauth strategy'
end
