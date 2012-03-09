require "omniauth/oauth"
require "multi_json"

module OmniAuth
  module Strategies
	  # Authenticate to Mendeley via OAuth and retrieve basic user information.
    #
    # Usage:
    #    use OmniAuth::Strategies::Mendeley, 'consumer_key', 'consumer_secret'
    class Mendeley < OmniAuth::Strategies::OAuth
      def initialize(app, consumer_key = nil, consumer_secret = nil, &block)
         client_options = {
           :site                => "http://www.mendeley.com",
           :request_token_path  => "http://www.mendeley.com/oauth/request_token/",
           :access_token_path   => "http://www.mendeley.com/oauth/access_token/",
           :authorize_url       => "http://www.mendeley.com/oauth/authorize/",
           :http_method         => :get,
           :scheme              => :query_string
         }

         super(app, :mendeley, consumer_key, consumer_secret, client_options, &block)
       end
       
       def auth_hash
         OmniAuth::Utils.deep_merge(
           super, {
             "uid" => user_data["main"]["profile_id"],
             "user_info" => user_info,
           }
         )
       end

       def user_data
         @data ||= MultiJson.decode(@access_token.get("/oapi/profiles/info/me").body)
       end

       def user_info
         {
           "name" => user_data["main"]["name"],
           "uid" => user_data["main"]["profile_id"]
         }
       end

      def callback_phase
        session["oauth"][name.to_s]["callback_confirmed"] = true

        super
      end
    end
  end
end