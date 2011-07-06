require 'omniauth/oauth'
require 'multi_json'
require 'hmac-sha1'
module OmniAuth
  module Strategies
    class Snda < OAuth2
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://oauth.snda.com',
          :authorize_url => '/oauth/authorize',
          :access_token_url => '/oauth/token',
        }

        super(app, :snda, consumer_key, consumer_secret, client_options, options, &block)
      end

      protected
      
      def calculate_signature(params, secret)        
        str=""
        params.sort.each {|k,v|
          unless (v.instance_of?(Hash))
            str = str + "#{k}=#{v}"
          else            
            str = str + "#{k}=" + MultiJson.decode(v.sort)
          end
        }
        s=HMAC::SHA1.new()
        s.set_key(secret)
        s.update(str)
        s.hexdigest
      end

      def user_data
        request_params = {
          'method' => 'sdo.accountdisplay_outer.displayacc_outer.DisplayAccount',
          'sdid'=>@access_token['sdid'],
          'oauth_consumer_key'=>self.client_id,
          'oauth_token' => @access_token.token,
          'oauth_nonce'=>rand(0),
          'oauth_timestamp'=>Time.new.to_s,
          'oauth_signature_method'=>'HMAC-SHA1',
          'oauth_version'=>'2.0'
        }

        request_params.merge!('oauth_signature' => calculate_signature(request_params,self.client_secret))
        @data ||= MultiJson.decode(client.request(:get, 'http://api.snda.com/', request_params))['data']
        @data['id']=@access_token['sdid']
        return @data
      end

      def request_phase
        options[:response_type] ||= "code"
        super
      end

      def callback_phase
        options[:grant_type] ||= 'authorization_code'
        super
      end

      def user_info
        {
          'account' => user_data['account'],
          'username'=> user_data['username'],
          'nickname'=> user_data['nickname'],
          'gender'=> user_data['gender'],
          'week_start'=> user_data['week_start'],
          'birthday_day'=> user_data['birthday_day'],
          'birthday_month'=> user_data['birthday_month'],
          'birthday_year'=> user_data['birthday_year'],
          'language'=> user_data['language'],
          'user_timezone'=> user_data['user_timezone'],
          'remind_email'=> user_data['remind_email'],
          'created'=> user_data['created'],
          'updated'=> user_data['updated']
        }
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
            'uid' => user_data['id'],
            'user_info' => user_info,
            'extra' => {'user_hash' => user_data}
          })
      end
    end
  end
end
