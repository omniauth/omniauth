# OmniAuth: Standardized Multi-Provider Authentication
OmniAuth is a new Rack-based authentication system for multi-provider external
authentcation. OmniAuth is built from the ground up on the philosophy that
**authentication is not the same as identity**, and is based on two
observations:

1. The traditional 'sign up using a login and password' model is becoming the
   exception, not the rule. Modern web applications offer external
   authentication via OpenID, Facebook, and/or OAuth.
2. The interconnectable web is no longer a dream, it is a necessity. It is not
   unreasonable to expect that one application may need to be able to connect
   to one, three, or twelve other services. Modern authentication systems
   should allow a user's identity to be associated with many authentications.

## <a name="installation">Installation</a>
To install OmniAuth, simply install the gem:

    gem install omniauth

## <a name="ci">Continuous Integration</a>
[![Build Status](https://travis-ci.org/intridea/omniauth.png)](http://travis-ci.org/intridea/omniauth)

## <a name="providers">Providers</a>
OmniAuth currently supports the following external providers:

* via OAuth (OAuth 1.0, OAuth 2, and xAuth)
  * 37signals ID (credit: [mbleigh](https://github.com/mbleigh))
  * AngelList (credit: [joshuaxls](https://github.com/joshuaxls))
  * Bit.ly (credit: [philnash](https://github.com/philnash))
  * Blogger (credit: [dsueiro-backing](https://github.com/dsueiro-backing))
  * Cobot (credit: [kamal](https://github.com/kamal))
  * DailyMile (credit: [cdmwebs](https://github.com/cdmwebs))
  * Doit.im (credit: [chouti](https://github.com/chouti))
  * Dopplr (credit: [flextrip](https://github.com/flextrip))
  * Douban (credit: [quake](https://github.com/quake))
  * Evernote (credit: [szimek](https://github.com/szimek))
  * Facebook (credit: [mbleigh](https://github.com/mbleigh))
  * Foursquare (credit: [mbleigh](https://github.com/mbleigh))
  * GitHub (credit: [mbleigh](https://github.com/mbleigh))
  * Glitch (credit: [harrylove](https://github.com/harrylove))
  * GoodReads (credit: [cristoffer](https://github.com/christoffer))
  * Google Health (credit: [jaigouk](https://github.com/jaigouk))
  * Gowalla (credit: [kvnsmth](https://github.com/kvnsmth))
  * Hyves (credit: [mrdg](https://github.com/mrdg))
  * Identi.ca (credit: [dcu](https://github.com/dcu))
  * Flattr (credit: [dcu](https://github.com/dcu))
  * Instagram (credit: [kiyoshi](https://github.com/kiyoshi))
  * Instapaper (credit: [micpringle](https://github.com/micpringle))
  * LastFM (credit: [tictoc](https://github.com/tictoc))
  * LinkedIn (credit: [mbleigh](https://github.com/mbleigh))
  * Mailchimp (via [srbiv](http://github.com/srbiv))
  * Mailru (credit: [lexer](https://github.com/lexer))
  * Meetup (credit [coderoshi](https://github.com/coderoshi))
  * Miso (credit: [rickenharp](https://github.com/rickenharp))
  * Mixi (credit: [kiyoshi](https://github.com/kiyoshi))
  * Netflix (credit: [caged](https://github.com/caged))
  * Orkut (credit: [andersonleite](https://github.com/andersonleite))
  * Plurk (credit: [albb0920](http://github.com/albb0920))
  * Qzone (credit: [quake](https://github.com/quake))
  * Rdio (via [brandonweiss](https://github.com/brandonweiss))
  * Renren (credit: [quake](https://github.com/quake))
  * Salesforce (via [CloudSpokes](http://www.cloudspokes.com))
  * SmugMug (credit: [pchilton](https://github.com/pchilton))
  * SoundCloud (credit: [leemartin](https://github.com/leemartin))
  * T163 (credit: [quake](https://github.com/quake))
  * Taobao (credit: [l4u](https://github.com/l4u))
  * TeamBox (credit [jrom](https://github.com/jrom))
  * Tqq (credit: [quake](https://github.com/quake))
  * TradeMe (credit: [pchilton](https://github.com/pchilton))
  * TripIt (credit: [flextrip](https://github.com/flextrip))
  * Tsina (credit: [quake](https://github.com/quake))
  * Tsohu (credit: [quake](https://github.com/quake))
  * Tumblr (credit: [jamiew](https://github.com/jamiew))
  * Twitter (credit: [mbleigh](https://github.com/mbleigh))
  * Viadeo (credit: [guillaug](https://github.com/guillaug))
  * Vimeo (credit: [jamiew](https://github.com/jamiew))
  * Vkontakte (credit: [german](https://github.com/german))
  * WePay (credit: [ryanwood](https://github.com/ryanwood))
  * Yahoo (credit: [mpd](https://github.com/mpd))
  * Yammer (credit: [kltcalamay](https://github.com/kltcalamay))
  * YouTube (credit: [jamiew](https://github.com/jamiew))
* CAS (Central Authentication Service) (credit: [jamesarosen](https://github.com/jamesarosen))
* Flickr (credit: [pchilton](https://github.com/pchilton))
* Google Apps (via OpenID) (credit: [mbleigh](https://github.com/mbleigh))
* Google OpenID+OAuth (via Hybrid Protocol) (credit: [boyvanamstel](https://github.com/boyvanamstel))
* LDAP (credit: [pyu10055](https://github.com/pyu10055))
* OpenID (credit: [mbleigh](https://github.com/mbleigh))
* Yupoo (credit: [chouti](https://github.com/chouti))

## <a name="usage">Usage</a>
OmniAuth is a collection of Rack middleware. To use a single strategy, you simply need to add the middleware:

    require 'oa-oauth'
    use OmniAuth::Strategies::Twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'

Now to initiate authentication you merely need to redirect the user to `/auth/twitter` via a link or other means. Once the user has authenticated to Twitter, they will be redirected to `/auth/twitter/callback`. You should build an endpoint that handles this URL, at which point you will have access to the authentication information through the `omniauth.auth` parameter of the Rack environment. For example, in Sinatra you would do something like this:

    get '/auth/twitter/callback' do
      auth_hash = request.env['omniauth.auth']
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

## <a name="resources">Resources</a>
The best place to find more information is the [OmniAuth Wiki](https://github.com/intridea/omniauth/wiki). Some specific information you might be interested in:

* [CI Build Status](http://travis-ci.org/intridea/omniauth)
* [Roadmap](https://github.com/intridea/omniauth/wiki/Roadmap)
* [Changelog](https://github.com/intridea/omniauth/wiki/Changelog)
* [Report Issues](https://github.com/intridea/omniauth/issues)
* [Mailing List](http://groups.google.com/group/omniauth)

## <a name="core">Core Team</a>
* **Michael Bleigh** ([mbleigh](https://github.com/mbleigh))
* **Erik Michaels-Ober** ([sferik](https://github.com/sferik))

## <a name="rubies">Supported Rubies</a>
This library aims to support and is [tested
against](http://travis-ci.org/intridea/omniauth) the following Ruby
implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* [JRuby](http://www.jruby.org/)
* [Rubinius](http://rubini.us/)
* [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/)

If something doesn't work on one of these interpreters, it should be considered
a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be personally responsible for providing patches in a
timely fashion. If critical issues for a particular implementation exist at the
time of a major release, support for that Ruby version may be dropped.

## <a name="license">License</a>
OmniAuth is released under the MIT License.
