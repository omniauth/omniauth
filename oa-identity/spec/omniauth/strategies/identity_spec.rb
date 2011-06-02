require 'spec_helper'

class MockIdentity; end

describe OmniAuth::Strategies::Identity do 
  let(:auth_hash){ last_response.headers['env']['omniauth.auth'] }
  
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

  describe '#registration_form' do
    it 'should trigger from /auth/identity/register by default' do
      get '/auth/identity/register'
      last_response.body.should be_include("Register Identity")
    end
  end

  describe '#registration_phase' do
    context 'with successful creation' do
      let(:properties){ {
        :name => 'Awesome Dude', 
        :email => 'awesome@example.com',
        :password => 'face',
        :password_confirmation => 'face'
      } }

      before do
        MockIdentity.should_receive(:create).with(properties).and_return(mock(:id => 1, :uid => 'abc', :name => 'Awesome Dude', :email => 'awesome@example.com', :user_info => {:name => 'DUUUUDE!'}))
      end

      it 'should set the auth hash' do
        post '/auth/identity/register', properties
        auth_hash['uid'].should == 'abc'
      end
    end

    context 'with invalid identity' do
      let(:properties) { {
        :name => 'Awesome Dude', 
        :email => 'awesome@example.com',
        :password => 'NOT',
        :password_confirmation => 'MATCHING'
      } }

      before do
        MockIdentity.should_receive(:create).with(properties).and_return(mock(:id => nil))
      end

      it 'should show registration form' do
        post '/auth/identity/register', properties
        last_response.body.should be_include("Register Identity")
      end
    end
  end
end
