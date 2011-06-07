require 'spec_helper'

class MockIdentity; end

describe OmniAuth::Strategies::Identity do
  attr_accessor :app

  let(:auth_hash){ last_response.headers['env']['omniauth.auth'] }
  let(:identity_hash){ last_response.headers['env']['omniauth.identity'] }

  # customize rack app for testing, if block is given, reverts to default
  # rack app after testing is done
  def set_app!(identity_options = {})
    identity_options.reverse_merge!({:model => MockIdentity})
    old_app = self.app
    self.app = Rack::Builder.app do
      use Rack::Session::Cookie
      use OmniAuth::Strategies::Identity, identity_options
      run lambda{|env| [404, {'env' => env}, ["HELLO!"]]}
    end
    if block_given?
      yield
      self.app = old_app
    end
    self.app
  end

  before(:all) do
    set_app!
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
        m = mock(:uid => 'abc', :name => 'Awesome Dude', :email => 'awesome@example.com', :user_info => {:name => 'DUUUUDE!'}, :persisted? => true)
        MockIdentity.should_receive(:create).with(properties).and_return(m)
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
        MockIdentity.should_receive(:create).with(properties).and_return(mock(:persisted? => false))
      end

      context 'default' do
        it 'should show registration form' do
          post '/auth/identity/register', properties
          last_response.body.should be_include("Register Identity")
        end
      end

      context 'custom on_failed_registration endpoint' do
        it 'should set the identity hash' do
          set_app!(:on_failed_registration => lambda{|env| [404, {'env' => env}, ["HELLO!"]]}) do
            post '/auth/identity/register', properties
            identity_hash.should_not be_nil
          end
        end
      end
    end
  end
end
