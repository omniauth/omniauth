require 'spec_helper'

class MockIdentity; end

describe OmniAuth::Strategies::Identity do 
  def app
    Rack::Builder.app do
      use Rack::Session::Cookie
      use OmniAuth::Strategies::Identity, :model => MockIdentity
      run lambda{|env| [404, {'env' => env}, ["HELLO!"]]}
    end
  end

  describe '#request_phase' do
    it 'should display a form' do
      get '/auth/identity'
      last_response.body.should be_include("<form")
    end
  end

  describe '#callback_phase' do
    let(:user){ mock(:uid => 'user1', :user_info => {'name' => 'Rockefeller'})}
    let(:auth_hash){ last_response.headers['env']['omniauth.auth'] }

    context 'with valid credentials' do
      before do
        MockIdentity.should_receive('authenticate').with('john','awesome').and_return(user)
        post '/auth/identity/callback', :auth_key => 'john', :password => 'awesome'
      end

      it 'should populate the auth hash' do
        auth_hash.should be_kind_of(Hash)
      end

      it 'should populate the uid' do
        auth_hash['uid'].should == 'user1'
      end

      it 'should populate the user_info hash' do
        auth_hash['user_info'].should == {'name' => 'Rockefeller'}
      end
    end

    context 'with invalid credentials' do
      before do
        OmniAuth.config.on_failure = lambda{|env| [401, {}, [env['omniauth.error.type'].inspect]]}
        MockIdentity.should_receive(:authenticate).with('wrong','login').and_return(false)
        post '/auth/identity/callback', :auth_key => 'wrong', :password => 'login'
      end

      it 'should fail with :invalid_credentials' do
        last_response.body.should == ':invalid_credentials'
      end
    end
  end

  describe '#registration_phase' do
    it 'should trigger from /auth/identity/register by default' do
      get '/auth/identity/register'
      last_response.body.should be_include("Register Identity")
    end
  end
end
