# OmniAuth: Standardized Multi-Provider Authentication

I know what you're thinking: yes, it's yet **another** authentication solution for Rack applications. But we're going to do things a little bit differently this time. OmniAuth is built from the ground up on the philosophy that **authentication is not the same as identity**. OmniAuth is based on two observations:

1. The traditional 'sign up using a login and password' model is becoming the exception, not the rule. Modern web applications offer external authentication via OpenID, Facebook, and/or OAuth.
2. The interconnectable web is no longer a dream, it is a necessity. It is not unreasonable to expect that one application may need to be able to connect to one, three, or twelve other services. Modern authentication systems should a user's identity to be associated with many authentications.

## Theoretical Framework

OmniAuth works on the principle that every authentication system can essentially be boiled down into two "phases".

### The Request Phase

In the Request Phase, we *request* information from the user that is necessary to complete authentication. This information may be **POST**ed to a URL or performed externally through an authentication process such as OpenID.

### The Callback Phase

In the Callback Phase, we receive an authenticated **unique identifier** that can differentiate this user from other users of the same authentication system. Additionally, we may provide **user information** that can be automatically harvested by the application to fill in the details of the authenticating user.

## Practical Implementation

In practical terms, OmniAuth is a collection of Rack middleware, each of which represent an **authentication provider**. The officially maintained providers are:

* Password (simple SHA1 encryption)
* OpenID
* OAuth
  * Twitter
  * LinkedIn
* OpenID
* Facebook

These middleware all follow a consistent pattern in that they initiate the **request phase** when the browser is directed (with additional information in some cases) to `/auth/provider_name`. They then all end their authentication process by calling the main Rack application at the endpoint `/auth/provider_name/callback` with request parameters pre-populated with an `auth` hash containing:

* `'provider'` - The provider name
* `'uid'` - The unique identifier of the user
* `'credentials'` - A hash of credentials for access to protected resources from the authentication provider (OAuth, Facebook)
* `'user_info'` - Additional information about the user

What this means is that, for all intents and purposes, your application needs only be concerned with *directing the user to the requesst phase* and *managing user information and session upon authentication callback*. All of the implementation details of the different authentication providers can be treated as a black box.

## Examples

### An Authentication Hash

    params['auth'] = {
      'provider' => 'Twitter',
      'uid' => '1234567',
      'credentials => {
        'token' => 'abc',
        'secret' => 'def'
      },
      'user_info' => {
        'name' => 'Michael Bleigh',
        'nickname' => 'mbleigh',
        'location' => 'Canton, MI',
        'image' => 'http://aws.twitter.com/...',
        'urls' => {'Website' => 'http://www.mbleigh.com/'}
      },
      'extra' => {
        'twitter_user' => {
          'id' => 1234567,
          'screen_name' => 'mbleigh'
          # ...
        }
      }
    }

### Sinatra

    require 'rubygems'
    require 'sinatra'
    require 'omniauth'
    require 'openid/store/filesystem'
    
    use OmniAuth::Builder do
      provider :open_id, OpenID::Store::Filesystem.new('/tmp')
      provider :twitter, 'consumerkey', 'consumersecret'
    end
    
    get '/' do
      <<-HTML
      <a href='/auth/twitter'>Sign in with Twitter</a>
      
      <form action='/auth/open_id' method='post'>
        <input type='text' name='identifier'/>
        <input type='submit' value='Sign in with OpenID'/>
      </form>
      HTML
    end
    
    get '/auth/:name/callback' do
      auth = params['auth']
      # do whatever you want with the information!
    end