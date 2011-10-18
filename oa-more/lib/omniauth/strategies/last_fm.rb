require 'omniauth/core'
require 'digest/md5'
require 'rest-client'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to LastFM
    #
    # @example Basic Usage
    #
    # use OmniAuth::Strategies::LastFm, 'API Key', 'Secret Key'
    class LastFm
      include OmniAuth::Strategy
      attr_accessor :api_key, :secret_key, :options

      # error catching, based on OAuth2 callback
      class CallbackError < StandardError
        attr_accessor :error, :error_reason
        def initialize(error, error_reason)
          self.error = error
          self.error_reason = error_reason
        end
      end

      # @param [Rack Application] app standard middleware application parameter
      # @param [String] api_key the application id as [registered on LastFM](http://www.last.fm/api/account)
      # @param [String] secret_key the application secret as [registered on LastFM](http://www.last.fm/api/account)
      # @option options, You can optionally specify a callback URL that is different to your API Account callback url. Include this as a query param cb
      def initialize(app, api_key, secret_key, options = {})
        super(app, :last_fm)
        @api_key = api_key
        @secret_key = secret_key
        @options = options
      end

      protected

      def request_phase
        params = { :api_key => api_key, :cb => options[:cb] }
        query_string = params.collect{ |key,value| "#{key}=#{Rack::Utils.escape(value)}" }.join('&')
        redirect "http://www.last.fm/api/auth/?#{query_string}"
      end
      
      def callback_phase
        token = request.params['token']
        params = { :api_key => api_key, :method => 'auth.getSession', :format => 'json' }
        params[:token] = token
        params[:api_sig] = signature(token)
      
        response = RestClient.get('http://ws.audioscrobbler.com/2.0/', { :params => params })
        @auth = MultiJson.decode(response.to_s)
        raise CallbackError.new(@auth['error'],@auth['message']) if @auth['error']
        
        user_params = { :method => "user.getInfo", :user => @auth['session']['name'], :api_key => api_key, :format => "json" }
        user_response = RestClient.get('http://ws.audioscrobbler.com/2.0/', { :params => user_params })
        @user_auth = MultiJson.decode(user_response.to_s)
        raise CallbackError.new(@user_auth['error'],@user_auth['message']) if @user_auth['error']
      
        super
      rescue CallbackError => e
        fail!(:invalid_response, e)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @user_auth['user']['id'],
          'credentials' => { 'token' => @auth['session']['key'] },
          'user_info' => user_info,
          'extra' => { 'user_hash' => @user_auth }
        })
      end
      
      def user_info
        {
          'name' => @user_auth['user']['realname'],
          'nickname' => @user_auth['user']['name'],
          'location' => @user_auth['user']['country'],
          'image' => @user_auth['user']['image'],
          'urls' => {
            'Profile' => @user_auth['user']['url']
          }
        }
      end
      
      def signature(token)
        sign = "api_key#{api_key}methodauth.getSessiontoken#{token}#{secret_key}"
        Digest::MD5.hexdigest(sign)
      end      
    end
  end
end
