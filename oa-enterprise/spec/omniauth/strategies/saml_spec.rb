require File.expand_path('../../../spec_helper', __FILE__)

describe OmniAuth::Strategies::SAML, :type => :strategy do
  
  include OmniAuth::Test::StrategyTestCase
  
  def strategy
    [OmniAuth::Strategies::SAML, {
      :assertion_consumer_service_url => "http://consumer.service.url/auth/saml/callback",
      :issuer                         => "https://saml.issuer.url/issuers/29490",
      :idp_sso_target_url             => "https://idp.sso.target_url/signon/29490",
      :idp_cert_fingerprint           => "E7:91:B2:E1:4C:65:2C:49:F3:33:74:0A:58:5A:7E:55:F7:15:7A:33",
      :name_identifier_format         => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    }]
  end

  describe 'GET /auth/saml' do
    before do
      get '/auth/saml'
    end

    it 'should get authentication page' do
      last_response.should be_redirect
    end
  end

  describe 'POST /auth/saml/callback' do

    it 'should raise ArgumentError exception without the SAMLResponse parameter' do
      post '/auth/saml/callback'
      last_response.should be_redirect
      last_response.location.should == '/auth/failure?message=invalid_ticket'
    end

  end
  
end