# OmniAuth: Standardized Multi-Provider Authentication

OmniAuth is a new Rack-based authentication system for multi-provider external authentcation. OmniAuth is built from the ground up on the philosophy that **authentication is not the same as identity**, and is based on two observations:

1. The traditional 'sign up using a login and password' model is becoming the exception, not the rule. Modern web applications offer external authentication via OpenID, Facebook, and/or OAuth.
2. The interconnectable web is no longer a dream, it is a necessity. It is not unreasonable to expect that one application may need to be able to connect to one, three, or twelve other services. Modern authentication systems should allow a user's identity to be associated with many authentications.

## Installation

To install OmniAuth, simply install the gem:

    gem install omniauth
    
## Providers

OmniAuth currently supports the following external providers:

* via OAuth
  * Facebook
  * Twitter
  * 37signals ID
  * Foursquare
  * LinkedIn
  * GitHub
* OpenID
* Google Apps (via OpenID)

## Usage

OmniAuth is a collection of Rack middleware. To use a single strategy, you simply need to add the middleware:

    require 'oa-oauth'
    use OmniAuth::Strategies::Twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
    
Now to initiate authentication you merely need to redirect the user to `/auth/twitter` via a link or other means. Once the user has authenticated to Twitter, they will be redirected to `/auth/twitter/callback`. You should build an endpoint that handles this URL, at which point you will will have access to the authentication information through the `rack.auth` parameter of the Rack environment. For example, in Sinatra you would do something like this:

    get '/auth/twitter/callback' do
      auth_hash = request.env['rack.auth']
    end
    
The hash in question will look something like this:

    {
      'uid' => '12356',
      'provider' => 'twitter',
      'user_info' => {
        'name' => 'User Name',
        'nickname' => 'username',
        # ...
      }
    }
    
The `user_info` hash will automatically be populated with as much information about the user as OmniAuth was able to pull from the given API or authentication provider.

## Resources

The best place to find more information is the [OmniAuth Wiki](http://github.com/intridea/omniauth/wiki). Some specific information you might be interested in:

* [Roadmap](http://github.com/intridea/omniauth/wiki/Roadmap)
* [Changelog](http://github.com/intridea/omniauth/wiki/Changelog)
* [Report Issues](http://github.com/intridea/omniauth/issues)
* [Mailing List](http://groups.google.com/group/omniauth)