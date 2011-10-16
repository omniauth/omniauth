require 'spec_helper'

describe OmniAuth::Strategies::Developer do
  let(:app){ Rack::Builder.new do |b|
    b.use Rack::Session::Cookie
    b.use OmniAuth::Strategies::Developer
    b.run lambda{|env| [200, {}, ['Not Found']]}
  end.to_app }

  context 'request phase' do
    before(:each){ get '/auth/developer' }

    it 'should display a form' do
      last_response.status.should == 200
      last_response.body.should be_include("<form")
    end

    it 'should have the callback as the action for the form' do
      last_response.body.should be_include("action='/auth/developer/callback'")
    end

    it 'should have a text field for each of the fields' do
      last_response.body.scan('<input').size.should == 2
    end
  end

  context 'callback phase' do
    let(:auth_hash){ last_request.env['omniauth.auth'] }

    context 'with default options' do
      before do
        post '/auth/developer/callback', :name => 'Example User', :email => 'user@example.com'
      end

      it 'should set the name in the auth hash' do
        auth_hash.info.name.should == 'Example User'
      end

      it 'should set the email in the auth hash' do
        auth_hash.info.email.should == 'user@example.com'
      end

      it 'should set the uid to the email' do
        auth_hash.uid.should == 'user@example.com'
      end
    end

    context 'with custom options' do
      let(:app){ Rack::Builder.new do |b|
        b.use Rack::Session::Cookie
        b.use OmniAuth::Strategies::Developer, :fields => [:first_name, :last_name], :uid_field => :last_name
        b.run lambda{|env| [200, {}, ['Not Found']]}
      end.to_app }

      before do
        @options = {:uid_field => :last_name, :fields => [:first_name, :last_name]}
        post '/auth/developer/callback', :first_name => 'Example', :last_name => 'User'
      end

      it 'should set info fields properly' do
        auth_hash.info.name.should == 'Example User'
      end

      it 'should set the uid properly' do
        auth_hash.uid.should == 'User'
      end
    end
  end
end
