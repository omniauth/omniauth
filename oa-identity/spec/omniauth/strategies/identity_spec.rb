require 'spec_helper'

module OmniAuth
  module Identity
    class Model
    end
  end
end

describe OmniAuth::Strategies::Identity do
  def app
    b = Rack::Builder.new
    b.use Rack::Session::Cookie
    b.use OmniAuth::Strategies::Identity, @options
    b.run @rack_app || lambda{|env| [@status || 404, {'env' => env}, ["Boing"]]}
    b.to_app
  end

  before(:each) do
    OmniAuth.config.on_failure = lambda{|env| [500, {}, [env['omniauth.error.type'].to_s]]}
    @options = {:key => 'nickname'}
  end

  context 'request phase' do
    it 'should display a form' do
      get '/auth/identity'
      last_response.body.should be_include("<form")
    end

    it 'should request the specified key' do
      pending "Let's get the basics working first."
      @options = {:key => 'email'}
      get '/auth/identity'
      last_response.body.should be_include("Email")
    end
  end

  context 'callback phase' do
    context 'with an existing user' do
      it 'should return the user info if a correct password is specified' do
        OmniAuth::Identity::Model.should_receive(:identify).
                                  with('nickname','existing','correct').
                                  and_return({'uid' => '123abc'})
        post '/auth/identity/callback', :key => 'existing', :password => 'correct'
        last_response.headers['env']['omniauth.auth']['uid'].should == '123abc'
      end

      it 'should fail with :invalid_credentials if no user exists' do
        OmniAuth::Identity::Model.should_receive(:identify).
                                  with('nickname','existing','wrong').
                                  and_return(nil)
        post '/auth/identity/callback', :key => 'existing', :password => 'wrong'

        last_response.status.should == 500
        last_response.body.should == 'invalid_credentials'
      end
    end 
  end
end
