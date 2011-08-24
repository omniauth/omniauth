require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Etsy < OmniAuth::Strategies::OAuth

      # Cribbed from the etsy gem.
      SANDBOX_HOST = 'sandbox.openapi.etsy.com'
      PRODUCTION_HOST = 'openapi.etsy.com'

      # Set the environment, accepts either :sandbox or :production. Defaults to :production
      # and will raise an exception when set to an unrecognized environment.
      def self.environment=(environment)
        unless [:sandbox, :production].include?(environment)
          raise(ArgumentError, "environment must be set to either :sandbox or :production")
        end
        @environment = environment
        @host = (environment == :sandbox) ? SANDBOX_HOST : PRODUCTION_HOST
      end

      # The currently configured environment.
      def self.environment
        @environment || :production
      end

      def self.host # :nodoc:
        @host || PRODUCTION_HOST
      end

      def self.callback_url
        @callback_url || 'oob'
      end

      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        # Set environment first; this can update our host
        OmniAuth::Strategies::Etsy.environment=options[:environment] if options[:environment]
        client_options = {
          :site => "http://#{OmniAuth::Strategies::Etsy.host}",
          :request_token_path => request_token_path(options),
          :access_token_path => access_token_path,
          :http_method => :get,
          :scheme => :query_string
        }

        super(app, :etsy, consumer_key, consumer_secret, client_options, options, &block)
      end

      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => true, 'request_token' => request_token.token, 'request_secret' => request_token.secret}
        r = Rack::Response.new
        if request_token.params[:login_url]
          # Already contains token, etc, of the form:
          # https://www.etsy.com/oauth/signin?oauth_consumer_key=wg30ji4z8kdzsymfkw9vm333&oauth_token=650a9d4a8d589bb7e6aefed1628885&service=v2_prod
          r.redirect(request_token.params[:login_url])
        end
        r.finish
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['user_id'],
          'user_info' => user_info,
          'extra' => { 'user_hash' => user_hash }
        })
      end

      def user_info
        return {} unless user_hash
        {
          'uid' => user_hash['user_id'],
          'nickname' => user_hash['login_name'],
          'email' => user_hash['primary_email'],
          'name' => user_hash['login_name'],
          'feedback_info' => user_hash['feedback_info']
        }
      end

      def request_token_path(options)
        # Default scope is to read a user's private profile information, including email.  Scope is specified
        # as a uri-encoded query kv pair, "scope=scope_1+scope_2+...+scope_n"
        # For a full list of scope options, see: 
        # http://www.etsy.com/developers/documentation/getting_started/oauth
        "/v2/oauth/request_token?#{to_params({:scope => options.fetch(:scope, 'profile_r+email_r')})}"
      end

      def access_token_path
        "/v2/oauth/access_token"
      end

      def to_params(options)
        options.collect{|key, value| "#{key}=#{value}"}.join('&')
      end

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/v2/users/__SELF__').body)['results'][0]
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      rescue ::OAuth::Error => e
        raise e.response.inspect
      end
    end
  end
end
