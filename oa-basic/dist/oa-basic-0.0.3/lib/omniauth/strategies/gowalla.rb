# Gowalla's API isn't authenticated yet
# so this won't actually work at all it
# turns out.

# require 'omniauth/basic'
# 
# module OmniAuth
#   module Strategies
#     class Gowalla < OmniAuth::Strategies::HttpBasic #:nodoc:
#       def initialize(app, api_key)
#         super(app, :gowalla, nil, {'X-Gowalla-API-Key' => api_key, 'Accept' => 'application/json'})
#       end
#       
#       def endpoint
#         "http://#{request[:username]}:#{request[:password]}@api.gowalla.com/users/#{request[:username]}"
#       end
#     end
#   end
# end
