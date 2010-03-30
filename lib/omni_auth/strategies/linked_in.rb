module OmniAuth
  module Strategies
    class LinkedIn < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key, consumer_secret)
        super(app, :linked_in, consumer_key, consumer_secret,
                :site => 'https://api.linkedin.com',
                :request_token_path => '/uas/oauth/requestToken',
                :access_token_path => '/uas/oauth/accessToken',
                :authorize_path => '/uas/oauth/authorize',
                :scheme => :header)
      end
    end
  end
end