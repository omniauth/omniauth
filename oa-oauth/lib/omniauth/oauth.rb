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
    autoload :TripIt,             'omniauth/strategies/trip_it'
    autoload :Dopplr,             'omniauth/strategies/dopplr'
    autoload :Meetup,             'omniauth/strategies/meetup'
    autoload :SoundCloud,         'omniauth/strategies/sound_cloud'
    autoload :SmugMug,            'omniauth/strategies/smug_mug'
    autoload :Douban,             'omniauth/strategies/douban'
    autoload :Tsina,              'omniauth/strategies/tsina'
    autoload :T163,               'omniauth/strategies/t163'
    autoload :Tsohu,              'omniauth/strategies/tsohu'
    autoload :Tqq,                'omniauth/strategies/tqq'
  end
end
