require File.expand_path('../../../spec_helper', __FILE__)
require 'openssl'
require 'base64'

describe OmniAuth::Strategies::Facebook do
  it_should_behave_like "an oauth2 strategy"
  
  it "should extract Facebook signed request from cookie" do
    client_id, client_secret = '123', '53cr3tz'
    app = lambda { |env| [200, {}, ['allo']] }
    strategy = OmniAuth::Strategies::Facebook.new(app, client_id, client_secret)
    
    payload = {
      'algorithm' => 'HMAC-SHA256',
      'code' => 'm4c0d3z',
      'issued_at' => Time.now.to_i,
      'user_id' => '123456'
    }
    
    strategy.stub(:request) { 
      Rack::Request.new({ 
        "HTTP_COOKIE" => "fbsr_#{client_id}=#{signed_request(payload, client_secret)}"
      }) 
    }
    
    signed_request = strategy.signed_request
    signed_request.should eq(payload)
  end
  
private

  def signed_request(payload, secret)
    encoded_payload = base64_encode_url(MultiJson.encode(payload))
    encoded_signature = base64_encode_url(signature(encoded_payload, secret))
    [encoded_signature, encoded_payload].join('.')
  end
  
  def base64_encode_url(value)
    Base64.encode64(value).tr('+/', '-_').gsub(/\n/, '')
  end
  
  def signature(payload, secret, algorithm = OpenSSL::Digest::SHA256.new)
    OpenSSL::HMAC.digest(algorithm, secret, payload)
  end
end
