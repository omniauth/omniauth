require 'omniauth/core'
require 'digest/md5'
require 'rest-client'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to draugiem.lv and frype.com and others.
    #
    # @example Basic Usage
    #
    #     use OmniAuth::Strategies::Draugiem, 'API Key', 'App id'
    class Draugiem
      include OmniAuth::Strategy
      attr_accessor :api_key, :app_id, :options

      def initialize(app, api_key, app_id)
        super(app, :draugiem)
        @api_key  = api_key
        @app_id   = app_id
      end

      protected
      
      def request_phase
        params = {
          :app => @app_id,
          :redirect => callback_url,
          :hash => Digest::MD5.hexdigest("#{@api_key}#{callback_url}")
        }
        query_string = params.collect{ |key,value| "#{key}=#{Rack::Utils.escape(value)}" }.join('&')
        redirect "http://api.draugiem.lv/authorize/?#{query_string}"
      end
      
      def callback_phase
        if request.params['dr_auth_status'] == 'ok' && request.params['dr_auth_code']
          response = RestClient.get('http://api.draugiem.lv/json/', { :params => draugiem_authorize_params(request.params['dr_auth_code']) })
          auth = MultiJson.decode(response.to_s)
          unless auth['error']      
            @auth_data = auth          
            super
          else
            fail!(auth['error']['code'].to_s,auth["error"]["description"].to_s)
          end
        else
          fail!(:invalid_request)
        end
      rescue Exception => e
        fail!(:invalid_response, e)
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => @auth_data['uid'],
          'user_info' => get_user_info,
          'credentials' => {
            'apikey' => @auth_data['apikey']
          },
          'extra' => { 'user_hash' => @auth_data }
        })
      end
      
      private 

      def get_user_info
        if @auth_data['users'] && @auth_data['users'][@auth_data['uid']]
          user = @auth_data['users'][@auth_data['uid']]
          {
            'name' => "#{user['name']} #{user['surname']}",
            'nickname' => user['nick'],
            'first_name' => user['name'],
            'last_name' => user['surname'],
            'location' => user['place'],
            'age' => user['age'],
            'adult' => user['adult'],
            'image' => user['img'],
            'sex' => user['sex']
          }
        else
          {}
        end
      end

      def draugiem_authorize_params code
        {
          :action => 'authorize',
          :app => @api_key,
          :code => code
        }
      end
    end
  end
end
