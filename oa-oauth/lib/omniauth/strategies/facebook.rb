require 'omniauth/oauth'
require 'multi_json'

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
        if facebook_session.blank?
          super
        else
          callback_phase
        end
      end
      
      def callback_phase
        if request.params['error'] || request.params['error_reason']
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        end
        if facebook_session.blank?
          verifier = request.params['code']
          @access_token = client.web_server.get_access_token(verifier, :redirect_uri => callback_url)
        else
          @access_token = ::OAuth2::AccessToken.new(client, facebook_session['access_token'])
        end
        @env['omniauth.auth'] = auth_hash
        call_app!
      rescue ::OAuth2::HTTPError, ::OAuth2::AccessDenied, CallbackError => e
        fail!(:invalid_credentials, e)
      end
      
      def build_access_token
        if facebook_session.nil? || facebook_session.empty?
          super
        else
          @access_token = ::OAuth2::AccessToken.new(client, facebook_session['access_token'])
        end
      end

      def facebook_session
        session_cookie = request.cookies["fbs_#{client.id}"]
        if session_cookie
          @facebook_session ||= Rack::Utils.parse_query(session_cookie.gsub('"', ''))
        else
          nil
        end
      end      

      def user_info
        {
          'nickname' => user_data["link"].split('/').last,
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
      
      def user_exists?
        options[:fetch_user].try(:call, @name, facebook_session['uid']).present?
      end
      
      def auth_hash
        # if options.key?[:fetch_user] && options[:fetch_user]
        if facebook_session.present? && user_exists?
          OmniAuth::Utils.deep_merge(super, {
            'uid' => facebook_session['uid']
          })
        else
          OmniAuth::Utils.deep_merge(super, {
            'uid' => user_data['id'],
            'user_info' => user_info,
            'extra' => {'user_hash' => user_data}
          })
        end
      end
      
      def facebook_session
        @facebook_session ||= Rack::Utils.parse_query(request.cookies["fbs_#{SiteConfig[:facebook][:app_id]}"].gsub('"', ''))
      end
    end
  end
end
