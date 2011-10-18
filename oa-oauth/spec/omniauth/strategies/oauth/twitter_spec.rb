require 'spec_helper'

describe OmniAuth::Strategies::Twitter do
  it_should_behave_like 'an oauth strategy'

  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider :twitter, 'abc', 'def'
      end
      run lambda { |env| [404, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  it 'should use the authenticate path by default' do
    s = strategy_class.new(app, 'abc', 'def')
    s.consumer.options[:authorize_path].should == '/oauth/authenticate'
  end

  it 'should set options[:authorize_params] to { :force_login => "true" } if :force_login is true' do
    s = strategy_class.new(app, 'abc', 'def', :force_login => true)
    s.options[:authorize_params].should == { :force_login => 'true' }
  end

  it 'should use the authorize path if :sign_in is false' do
    s = strategy_class.new(app, 'abc', 'def', :sign_in => false)
    s.consumer.options[:authorize_path].should == '/oauth/authorize'
  end

  it 'should properly handle a timeout when fetching the user hash' do
    stub_request(:post, 'https://api.twitter.com/oauth/access_token').
       to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret")

    stub_request(:get, "https://api.twitter.com/1/account/verify_credentials.json").
      to_raise(Errno::ETIMEDOUT)

    get '/auth/twitter/callback', {:oauth_verifier => 'dudeman'}, {'rack.session' => {'oauth' => {"twitter" => {'callback_confirmed' => true, 'request_token' => 'yourtoken', 'request_secret' => 'yoursecret'}}}}

    last_request.env['omniauth.error'].should be_kind_of(::Timeout::Error)
    last_request.env['omniauth.error.type'] = :service_unavailable
  end
end
