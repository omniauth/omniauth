# OmniAuth::Cookie

Cookie based strategies for the OmniAuth gem.

The implementation of OmniAuth::Strategies::Renren is heavily based on [taweili](http://github.com/taweili)'s [renren](http://github.com/taweili/renren) gem.

## Installation

To get just Cookie functionality:

    gem install oa-cookie

For the full auth suite:

    gem install omniauth

## Stand-Alone Example

Use the strategy as a middleware in your application:

    require 'omniauth/cookie'

    use OmniAuth::Strategies::Renren, 'api_key', 'secret_key'

Run the generator to generate `xd_receiver.html` and include helper into ApplicationHelper:

    rails g omniauth_renren:install

Place the Renren Connect button on any page by simply call `omniauth_renren_connect_button`:

    <%= omniauth_renren_connect_button %>

Route `/auth/renren` to the page that contain Renren Connect button:

    match '/auth/renren' => 'users#show'

## OmniAuth Builder

If you want to allow multiple providers, use the OmniAuth Builder:

    require 'omniauth/oauth'

    use OmniAuth::Builder do
      provider :twitter, 'consumer_key', 'consumer_secret'
      provider :renren, 'api_key', 'secret_key'
    end

