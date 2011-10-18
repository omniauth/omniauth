require 'json'
require 'omniauth/oauth'

module OmniAuth
  module Strategies
    class MySpace < OmniAuth::Strategies::OAuth

      def initialize(app, consumer_key=nil, consumer_secret=nil, options={}, &block)
        client_options = {
          :site => 'http://api.myspace.com',
          :access_token_path => '/access_token',
          :authorize_path => '/authorize',
          :request_token_path => '/request_token',
          :http_method => "get"
        }
        options.merge! :http_method => :get
        super(app, :my_space, consumer_key, consumer_secret, client_options, options, &block)
      end

      def callback_phase
        session['oauth'][name.to_s]['callback_confirmed'] = true
        super
      end

      def user_data
        @access_token.options.merge!({:param_name => 'oauth_token', :mode => :query})
        # response = @access_token.post('/simple/players.info')
        # @data ||= MultiJson.decode(response.body)
      end

      def request_phase
        request_token = consumer.get_request_token(:oauth_callback => callback_url)
        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {'callback_confirmed' => request_token.callback_confirmed?, 'request_token' => request_token.token, 'request_secret' => request_token.secret}
        sleep 1
        if request_token.callback_confirmed?
          redirect request_token.authorize_url(options[:authorize_params])
        else
          redirect request_token.authorize_url(options[:authorize_params].merge(:oauth_callback => callback_url))
        end

      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      end

      def consumer
        ::OAuth::Consumer.new(consumer_key, consumer_secret, {
                :http_method=>"get",
                :site=>"http://api.myspace.com",
                :request_token_path=>"/request_token",
                :access_token_path=>"/access_token",
                :authorize_path=>"/authorize"
        })
      end

      def user_hash(access_token)
        person = JSON.parse( access_token.get("/v2/people/@me/@self?format=json").body )["users"].first

        hash = {
          'id'          => person['id'],
          'first_name'  => person['first_name'],
          'last_name'   => person['last_name'],
          'image'       => person["photo_urls"]["large"],
        }
      end

    end
  end
end
