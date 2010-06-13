require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :HttpBasic,  'omniauth/strategies/http_basic'
    autoload :Basecamp,   'omniauth/strategies/basecamp'
    autoload :Campfire,   'omniauth/strategies/campfire'
    # autoload :Gowalla,    'omniauth/strategies/gowalla'
  end
end
