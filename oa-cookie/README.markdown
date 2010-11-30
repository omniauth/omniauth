# OmniAuth::Cookie

Cookie based strategies for the OmniAuth gem.

## Installation

To get just Cookie functionality:

    gem install oa-cookie

For the full auth suite:

    gem install omniauth

## Stand-Alone Example

Use the strategy as a middleware in your application:

    require 'omniauth/cookie'

    use OmniAuth::Strategies::Renren, 'api_key', 'secret_key'

TODO: Generator and helper setup

## OmniAuth Builder

If you want to allow multiple providers, use the OmniAuth Builder:

    require 'omniauth/oauth'

    use OmniAuth::Builder do
      provider :twitter, 'consumer_key', 'consumer_secret'
      provider :renren, 'api_key', 'secret_key'
    end

