require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to ConstantContact via OAuth
    #
    # Usage:
    #
    #   use OmniAuth::Strategies::ConstantContact, 'consumerkey', 'consumersecret'
    #
    class ConstantContact < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://oauth.constantcontact.com',
          :request_token_path => '/ws/oauth/request_token',
          :access_token_path => '/ws/oauth/access_token',
          :authorize_path => '/ws/oauth/confirm_access',
          :http_method => :post,
          :scheme => :query_string
        }
        
        options.merge! :scheme => :query_string, :http_method => :post
        
        super(app, :constant_contact, consumer_key, consumer_secret, client_options, options)
      end

      # Constant Contact uses OAuth as an ACL only and has no user profile data to return.
      def auth_hash
        super
      end
    end
  end
end
