require File.expand_path('../../../spec_helper', __FILE__)
require 'rack/openid'
require 'omniauth/openid'

describe OmniAuth::Strategies::OpenID, :type => :strategy do

  include OmniAuth::Test::StrategyTestCase

  def strategy
    [OmniAuth::Strategies::OpenID]
  end

  def expired_query_string
    'openid=consumer&janrain_nonce=2011-07-21T20%3A14%3A56ZJ8LP3T&openid.assoc_handle=%7BHMAC-SHA1%7D%7B4e284c39%7D%7B9nvQeg%3D%3D%7D&openid.claimed_id=http%3A%2F%2Flocalhost%3A1123%2Fjohn.doe%3Fopenid.success%3Dtrue&openid.identity=http%3A%2F%2Flocalhost%3A1123%2Fjohn.doe%3Fopenid.success%3Dtrue&openid.mode=id_res&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.op_endpoint=http%3A%2F%2Flocalhost%3A1123%2Fserver%2F%3Fopenid.success%3Dtrue&openid.response_nonce=2011-07-21T20%3A14%3A56Zf9gC8S&openid.return_to=http%3A%2F%2Flocalhost%3A8888%2FDevelopment%2FWordpress%2Fwp_openid%2F%3Fopenid%3Dconsumer%26janrain_nonce%3D2011-07-21T20%253A14%253A56ZJ8LP3T&openid.sig=GufV13SUJt8VgmSZ92jGZCFBEvQ%3D&openid.signed=assoc_handle%2Cclaimed_id%2Cidentity%2Cmode%2Cns%2Cop_endpoint%2Cresponse_nonce%2Creturn_to%2Csigned'
  end

  describe '/auth/open_id without an identifier URL' do
    before do
      get '/auth/open_id'
    end

    it 'should respond with OK' do
      last_response.should be_ok
    end

    it 'should respond with HTML' do
      last_response.content_type.should == 'text/html'
    end

    it 'should render an identifier URL input' do
      last_response.body.should =~ %r{<input[^>]*#{OmniAuth::Strategies::OpenID::IDENTIFIER_URL_PARAMETER}}
    end
  end

  #describe '/auth/open_id with an identifier URL' do
  #  context 'successful' do
  #    before do
  #      @identifier_url = 'http://me.example.org'
  #      # TODO: change this mock to actually return some sort of OpenID response
  #      stub_request(:get, @identifier_url)
  #      get '/auth/open_id?openid_url=' + @identifier_url
  #    end
  #  
  #    it 'should redirect to the OpenID identity URL' do
  #      last_response.should be_redirect
  #      last_response.headers['Location'].should =~ %r{^#{@identifier_url}.*}
  #    end
  #  
  #    it 'should tell the OpenID server to return to the callback URL' do
  #      return_to = CGI.escape(last_request.url + '/callback')
  #      last_response.headers['Location'].should =~ %r{[\?&]openid.return_to=#{return_to}}
  #    end
  #  end 
  #end

  describe 'followed by /auth/open_id/callback' do
    context 'successful' do
      #before do
      #  @identifier_url = 'http://me.example.org'
      #  # TODO: change this mock to actually return some sort of OpenID response
      #  stub_request(:get, @identifier_url)
      #  get '/auth/open_id/callback'
      #end

      it "should set provider to open_id"
      it "should create auth_hash based on sreg"
      it "should create auth_hash based on ax"

      #it 'should call through to the master app' do
      #  last_response.body.should == 'true'
      #end
    end

    context 'unsuccessful' do
      describe 'returning with expired credentials' do
        before do
          get '/auth/open_id/callback?' + expired_query_string
        end
        it 'it should redirect to invalid credentials' do
          last_response.should be_redirect 
          last_response.headers['Location'].should =~ %r{invalid_credentials}
        end
      end
    end
  end

end
