require File.dirname(__FILE__) + '/../../spec_helper'

describe OmniAuth::Strategies::Password, :type => :strategy do

  include OmniAuth::Test::StrategyTestCase

  def strategy
    [OmniAuth::Strategies::Password, 'anything here', {:identifier_key => 'username'}]
  end
  
  describe 'GET /auth/password without a password' do
    before do
      get '/auth/password', { :identifier => 'jerome' }
    end
    it 'should be unauthorized' do
      last_response.should be_redirect
      last_request.env['omniauth.error.type'].should == :missing_information
    end
  end
  
  describe 'GET /auth/password with a username and password' do
    before do
      get '/auth/password', { :identifier => 'jerome', :password => 'my password'}
    end
    it 'should be OK' do
      last_response.should be_ok
    end
    sets_an_auth_hash
    sets_provider_to 'password'
    sets_user_info_to "username" => "jerome"
    it 'should set the UID to an opaque identifier' do
      uid = last_request.env['omniauth.auth']['uid']
      uid.should_not be_nil
      uid.should_not =~ /jerome/
      uid.should_not =~ /my password/
    end
  end

end
