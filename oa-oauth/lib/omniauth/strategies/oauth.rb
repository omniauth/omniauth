require 'oauth'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class OAuth
      include OmniAuth::Strategy
      
      def initialize(app, name, consumer_key = nil, consumer_secret = nil, consumer_options = {}, options = {}, &block)
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
        self.consumer_options = consumer_options
        super
      end
      
      def consumer
        ::OAuth::Consumer.new(consumer_key, consumer_secret, consumer_options.merge(options[:client_options] || options[:consumer_options] || {}))
      end

      attr_reader :name
      attr_accessor :consumer_key, :consumer_secret, :consumer_options
      
      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        (session[:oauth]||={})[name.to_sym] = {:callback_confirmed => request_token.callback_confirmed?, :request_token => request_token.token, :request_secret => request_token.secret}
        r = Rack::Response.new
        
        if request_token.callback_confirmed?
          r.redirect(request_token.authorize_url)
        else
          r.redirect(request_token.authorize_url(:oauth_callback => callback_url))        
        end
        
        r.finish
      end
    
      def callback_phase
        raise session[:oauth].inspect
        request_token = ::OAuth::RequestToken.new(consumer, session[:oauth][name.to_sym].delete(:request_token), session[:oauth][name.to_sym].delete(:request_secret))
        
        opts = {}
        opts[:oauth_callback] = callback_url if session[:oauth][:callback_confirmed]
        @access_token = request_token.get_access_token(opts)
        super
      rescue ::OAuth::Unauthorized => e
        raise e.inspect
        fail!(:invalid_credentials, e)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'credentials' => {
            'token' => @access_token.token, 
            'secret' => @access_token.secret
          }, 'extra' => {
            'access_token' => @access_token
          }
        })
      end
      
      def unique_id
        nil
      end
    end
  end
end
