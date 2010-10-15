require 'omniauth/core'

module OmniAuth
  module Strategies
    autoload :OAuth,              'omniauth/strategies/oauth'
    autoload :OAuth2,             'omniauth/strategies/oauth2'
    
    autoload :Twitter,            'omniauth/strategies/twitter'
    autoload :LinkedIn,           'omniauth/strategies/linked_in'
    autoload :Facebook,           'omniauth/strategies/facebook'
    autoload :GitHub,             'omniauth/strategies/github'
    autoload :ThirtySevenSignals, 'omniauth/strategies/thirty_seven_signals'
    autoload :Foursquare,         'omniauth/strategies/foursquare'
    autoload :Gowalla,            'omniauth/strategies/gowalla'
    autoload :Identica,           'omniauth/strategies/identica'
    autoload :Tripit,             'omniauth/strategies/tripit'
    autoload :Dopplr,             'omniauth/strategies/dopplr'
  end
end
