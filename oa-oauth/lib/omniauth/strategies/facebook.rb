require 'omniauth/oauth'
require 'multi_json'
require 'base64'
require 'openssl'

module OmniAuth
  module Strategies
    # Authenticate to Facebook utilizing OAuth 2.0 and retrieve
    # basic user information.
    #
    # @example Basic Usage
    #   use OmniAuth::Strategies::Facebook, 'client_id', 'client_secret'
    class Facebook < OAuth2
      # @param [Rack Application] app standard middleware application parameter
      # @param [String] client_id the application id as [registered on Facebook](http://www.facebook.com/developers/)
      # @param [String] client_secret the application secret as registered on Facebook
      # @option options [String] :scope ('email,offline_access') comma-separated extended permissions such as `email` and `manage_pages`
      def initialize(app, client_id = nil, client_secret = nil, options = {}, &block)
        super(app, :facebook, client_id, client_secret, {:site => 'https://graph.facebook.com/'}, options, &block)
      end

      def user_data
        @data ||= MultiJson.decode(@access_token.get('/me', {}, { "Accept-Language" => "en-us,en;"}))
      end

      def request_phase
        options[:scope] ||= "email,offline_access"
        super
      end

      def build_access_token
        if !signed_request.nil? && !signed_request.empty?
          verifier = signed_request['code']
          client.web_server.get_access_token(verifier, { :redirect_uri => '' }.merge(options))
        elsif !facebook_session.nil? && !facebook_session.empty? 
          @access_token = ::OAuth2::AccessToken.new(client, facebook_session['access_token'])
        else
          super
        end
      end

      def facebook_session
        session_cookie = request.cookies["fbs_#{client.id}"]
        if session_cookie
          @facebook_session ||= Rack::Utils.parse_query(request.cookies["fbs_#{client.id}"].gsub('"', ''))
        else
          nil
        end
      end
     
      def signed_request
        signed_request_cookie = request.cookies["fbsr_#{client.id}"]
        if signed_request_cookie
          @signed_request ||= parse_signed_request(signed_request_cookie)
        else
          nil
        end
      end
      
      def user_info
        {
          'nickname' => user_data["username"],
          'email' => (user_data["email"] if user_data["email"]),
          'first_name' => user_data["first_name"],
          'last_name' => user_data["last_name"],
          'name' => "#{user_data['first_name']} #{user_data['last_name']}",
          'image' => "http://graph.facebook.com/#{user_data['id']}/picture?type=square",
          'urls' => {
            'Facebook' => user_data["link"],
            'Website' => user_data["website"],
          }
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_data['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_data}
        })
      end
      
    private
      
      def parse_signed_request(value)
        signature, encoded_payload = value.split('.')
        
        decoded_hex_signature = base64_decode_url(signature)#.unpack('H*')
        decoded_payload = MultiJson.decode(base64_decode_url(encoded_payload))
        
        unless decoded_payload['algorithm'] == 'HMAC-SHA256'
          raise NotImplementedError, "unkown algorithm: #{decoded_payload['algorithm']}"
        end
        
        if valid_signature?(client.secret, decoded_hex_signature, encoded_payload)
          decoded_payload
        end
      end
      
      def valid_signature?(secret, signature, payload, algorithm = OpenSSL::Digest::SHA256.new)
        OpenSSL::HMAC.digest(algorithm, secret, payload) == signature
      end
      
      def base64_decode_url(value)
        value += '=' * (4 - value.size.modulo(4))
        Base64.decode64(value.tr('-_', '+/'))
      end
    end
  end
end
