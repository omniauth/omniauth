# OmniAuth: Standardized Multi-Provider Authentication

[![Gem Version](http://img.shields.io/gem/v/omniauth.svg)][gem]
[![Ruby](https://github.com/omniauth/omniauth/actions/workflows/main.yml/badge.svg)][githubactions]
[![TruffleRuby](https://github.com/omniauth/omniauth/actions/workflows/truffle_ruby.yml/badge.svg)][githubactionstruffle]
[![JRuby](https://github.com/omniauth/omniauth/actions/workflows/jruby.yml/badge.svg)][githubactionsjruby]
[![Maintainability](https://qlty.sh/gh/omniauth/projects/omniauth/maintainability.svg)][qlty]
[![Coverage Status](http://img.shields.io/coveralls/omniauth/omniauth.svg)][coveralls]
[![Duel](https://raw.githubusercontent.com/sferik/duel-ruby/main/assets/badge.svg)](https://github.com/sferik/duel-ruby)

[gem]: https://rubygems.org/gems/omniauth
[githubactions]: https://github.com/omniauth/omniauth/actions/workflows/main.yml
[githubactionstruffle]: https://github.com/omniauth/omniauth/actions/workflows/truffle_ruby.yml
[githubactionsjruby]: https://github.com/omniauth/omniauth/actions/workflows/jruby.yml
[qlty]: https://qlty.sh/gh/omniauth/projects/omniauth
[coveralls]: https://coveralls.io/r/omniauth/omniauth

This is the documentation for the in-development branch of OmniAuth.
You can find the documentation for the latest stable release [here](https://github.com/omniauth/omniauth/tree/v2.3.1)

## An Introduction
OmniAuth is a library that standardizes multi-provider authentication for
web applications. It was created to be powerful, flexible, and do as
little as possible. Any developer can create **strategies** for OmniAuth
that can authenticate users via disparate systems. OmniAuth strategies
have been created for everything from Facebook to LDAP.

In order to use OmniAuth in your applications, you will need to leverage
one or more strategies. These strategies are generally released
individually as RubyGems, and you can see a [community maintained list](https://github.com/omniauth/omniauth/wiki/List-of-Strategies)
on the wiki for this project.

One strategy, called `Developer`, is included with OmniAuth and provides
a completely insecure, non-production-usable strategy that directly
prompts a user for authentication information and then passes it
straight through. You can use it as a placeholder when you start
development and easily swap in other strategies later.

## Getting Started
Each OmniAuth strategy is a Rack Middleware. That means that you can use
it the same way that you use any other Rack middleware. For example, to
use the built-in Developer strategy in a Sinatra application you might
do this:

```ruby
require 'sinatra'
require 'omniauth'

class MyApplication < Sinatra::Base
  use Rack::Session::Cookie
  use OmniAuth::Strategies::Developer
end
```

Because OmniAuth is built for *multi-provider* authentication, you may
want to leave room to run multiple strategies. For this, the built-in
`OmniAuth::Builder` class gives you an easy way to specify multiple
strategies. Note that there is **no difference** between the following
code and using each strategy individually as middleware. This is an
example that you might put into a Rails initializer at
`config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
```

You should look to the documentation for each provider you use for
specific initialization requirements.

## Integrating OmniAuth Into Your Application
OmniAuth is an extremely low-touch library. It is designed to be a
black box that you can send your application's users into when you need
authentication and then get information back. OmniAuth was intentionally
built not to automatically associate with a User model or make
assumptions about how many authentication methods you might want to use
or what you might want to do with the data once a user has
authenticated. This makes OmniAuth incredibly flexible. To use OmniAuth,
you need only to redirect users to `/auth/:provider`, where `:provider`
is the name of the strategy (for example, `developer` or `twitter`).
From there, OmniAuth will take over and take the user through the
necessary steps to authenticate them with the chosen strategy.

Once the user has authenticated, what do you do next? OmniAuth simply
sets a special hash called the Authentication Hash on the Rack
environment of a request to `/auth/:provider/callback`. This hash
contains as much information about the user as OmniAuth was able to
glean from the utilized strategy. You should set up an endpoint in your
application that matches to the callback URL and then performs whatever
steps are necessary for your application. 

The `omniauth.auth` key in the environment hash provides an
Authentication Hash which will contain information about the just
authenticated user including a unique id, the strategy they just used
for authentication, and personal details such as name and email address
as available. For an in-depth description of what the authentication
hash might contain, see the [Auth Hash Schema wiki page](https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema).

Note that OmniAuth does not perform any actions beyond setting some
environment information on the callback request. It is entirely up to
you how you want to implement the particulars of your application's
authentication flow.

## Cross-Site Request Forgery (CSRF) protection

OmniAuth protects the request phase (`POST /auth/:provider`) against
[CSRF attacks](https://owasp.org/www-community/attacks/csrf) by default.
It uses [`OmniAuth::AuthenticityTokenProtection`](./lib/omniauth/authenticity_token_protection.rb),
a subclass of `Rack::Protection::AuthenticityToken` from the
[rack-protection](https://rubygems.org/gems/rack-protection) gem.

You can pass `Rack::Protection::AuthenticityToken` options to match how
your app stores its token. For example, to work with
[rack_csrf](https://github.com/baldowl/rack_csrf):

```ruby
OmniAuth::AuthenticityTokenProtection.default_options(
  key: "csrf.token",
  authenticity_param: "_csrf"
)
```

`Rack::Protection::AuthenticityToken` expects Base64-encoded tokens. If
your app handles CSRF tokens differently, use the `allow_if` option to
implement your own check.

For Rails, see [Rails (without Devise)](#rails-without-devise). For
more options, see the
[rack-protection documentation](https://www.rubydoc.info/gems/rack-protection/Rack/Protection/AuthenticityToken).

## Rails (without Devise)
To get started, add the gem

**Gemfile**:
```ruby
gem 'omniauth'
```

Then insert OmniAuth as a middleware

**config/initializers/omniauth.rb**:
```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?
end

OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)
```

The last line makes OmniAuth check the CSRF token Rails stores in the
session (`_csrf_token`), so the request phase uses the same token as
your forms.

Additional providers can be added here in the future. Next we wire it
all up using routes, a controller and a login view.

**config/routes.rb**:

```ruby
  get 'auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new'
```

**app/controllers/sessions_controller.rb**:
```ruby
class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    user_info = request.env['omniauth.auth']
    raise user_info.inspect # Your own session management should be placed here.
  end
end
```

**app/views/sessions/new.html.erb**:
```erb
<%= button_to "Login with Developer", "/auth/developer", data: { turbo: false } %>
```

Now if you visit `/login` and click the Login button, you should see the
OmniAuth developer login screen. After submitting it, you are returned to your
application at `Sessions#create`. The raise should now display all the Omniauth
details you have available to integrate it into your own user management.

If you want out of the box usermanagement, you should consider using Omniauth
through Devise. Please visit the [Devise Github page](https://github.com/heartcombo/devise#omniauth)
for more information.


## Rails API
The following middleware are (by default) included for session management in
Rails applications. When using OmniAuth with a Rails API, you'll need to add
one of these required middleware back in:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

The trick to adding these back in is that, by default, they are passed
`session_options` when added (including the session key), so you can't just add
a `session_store.rb` initializer, add `use ActionDispatch::Session::CookieStore`
and have sessions functioning as normal.

To be clear: sessions may work, but your session options will be ignored
(i.e. the session key will default to `_session_id`).  Instead of the
initializer, you'll have to set the relevant options somewhere
before your middleware is built (like `application.rb`) and pass them to your
preferred middleware, like this:

**application.rb:**

```ruby
config.session_store :cookie_store, key: '_interslice_session'
config.middleware.use ActionDispatch::Cookies # Required for all session management
config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
```

(Thanks @mltsy)

## Logging
OmniAuth supports a configurable logger. By default, OmniAuth will log
to `STDOUT` but you can configure this using `OmniAuth.config.logger`:

```ruby
# Rails application example
OmniAuth.config.logger = Rails.logger
```

## Full Host
OmniAuth builds the callback URL it sends to the provider from the
request's scheme and host. The host comes from the `Host` header, or
from `X-Forwarded-Host` or `Forwarded` when present, and a client can
forge any of them. A forged host sends the provider a `redirect_uri` on
someone else's site, so unless your app or a proxy in front of it
checks the host (as Rails does with `config.hosts`), tell OmniAuth which
host to use.

The simplest way is to set the host yourself, either for every provider
or for one, as a string or as a proc that takes the Rack env. A proc
shouldn't return a host taken from the request without checking it.

```ruby
OmniAuth.config.full_host = 'https://example.com'
provider :twitter, ENV['KEY'], ENV['SECRET'], full_host: 'https://admin.example.com'
```

A provider's `full_host` option takes precedence over `OmniAuth.config.full_host`.

If your app serves several hosts, list them instead. A string matches
the whole host, ignoring case, and a regexp must match the whole host.
A request on any other host fails with `invalid_host`.

```ruby
OmniAuth.config.allowed_hosts = ['example.com', /[a-z0-9-]+\.example\.com/]
```

Until one of these is set, OmniAuth logs a warning at the start of every
request phase.

## Origin Param
The `origin` parameter is typically used to inform where a user came from
and where, should you choose to use it, they'd want to return to. Send it in
the query string or, since the request phase is a POST, as a field in the
request form, e.g. `<input type="hidden" name="origin" value="[URL]">`.
Omniauth supports the following settings which can be configured on a provider level:

**Default**:
```ruby
provider :twitter, ENV['KEY'], ENV['SECRET']
POST /auth/twitter/?origin=[URL]
# If the `origin` parameter is blank, `omniauth.origin` is set to HTTP_REFERER
```

**Using a differently named origin parameter**:
```ruby
provider :twitter, ENV['KEY'], ENV['SECRET'], origin_param: 'return_to'
POST /auth/twitter/?return_to=[URL]
# If the `return_to` parameter is blank, `omniauth.origin` is set to HTTP_REFERER
```

**Disabled**:
```ruby
provider :twitter, ENV['KEY'], ENV['SECRET'], origin_param: false
POST /auth/twitter
# This means the origin should be handled by your own application. 
# Note that `omniauth.origin` will always be blank.
```

**Validate the origin before redirecting to it.** It comes from a request
parameter or the `Referer` header, so anyone can set it to any URL.
Redirecting to it unchecked (for example `redirect_to
request.env['omniauth.origin']`) makes your app an open redirect. Only
follow it if it's a path on your own site, and fall back to a default
otherwise:

```ruby
# A local path: starts with one slash, not // or /\ (which browsers
# treat as another host).
origin = request.env['omniauth.origin'].to_s
redirect_to(origin.match?(%r{\A/(?![/\\])}) ? origin : root_path)
```

The `Referer` fallback gives a full URL, which this check rejects. To
accept those too, parse the URL and compare its host with your own.

## The Rack Environment
OmniAuth passes information to your application in the Rack environment
(`request.env` in Rails).

On the callback request (`/auth/:provider/callback`):

| Key | Value |
| --- | --- |
| `omniauth.auth` | The [Authentication Hash](https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema) for the user who just signed in. |
| `omniauth.origin` | Where the user came from, if known (see [Origin Param](#origin-param)). |
| `omniauth.params` | The params sent to the request phase (`/auth/:provider`), from both the query string and the form, except `authenticity_token`. An empty hash if there were none. |
| `omniauth.strategy` | The strategy instance handling the request. Also set on the request phase and on the setup path. |

When authentication fails, OmniAuth calls `OmniAuth.config.on_failure`
with the environment, which also includes:

| Key | Value |
| --- | --- |
| `omniauth.error` | The exception that caused the failure, if there was one. |
| `omniauth.error.type` | A symbol describing the failure, such as `:invalid_credentials`. |
| `omniauth.error.strategy` | The strategy instance that failed. |

`omniauth.origin` and `omniauth.params` come from the user's request, so
treat them like any other request params and validate them before use.

The default `on_failure` raises the error in development and otherwise
redirects to `/auth/failure` with the `message`, `strategy`, and
`origin` as query string parameters.

## Session Cookies and SameSite
OmniAuth keeps its state between the request and callback phases (for
example the OAuth `state` parameter, `omniauth.origin`, and
`omniauth.params`) in the Rack session. When the provider redirects or
POSTs back to your callback from its own domain, the browser has to send
your session cookie with that cross-site request, or the callback fails
(often with a `csrf_detected` or invalid `state` error).

- With `SameSite=Lax`, the default in Rails and in modern browsers, the
  cookie is sent on top-level GET redirects back to your app, which covers
  most OAuth and OpenID Connect flows.
- With `SameSite=Strict`, it isn't, so the callback sees an empty session.
  Use `Lax` for the session cookie, or make the callback a same-site
  request by first answering it with a page that immediately reloads the
  same URL (for example with `<meta http-equiv="refresh">`), after which
  the browser sends the cookie.
- Providers that POST to the callback (such as SAML's HTTP-POST binding or
  OpenID Connect's `form_post` response mode) need `SameSite=None; Secure`.

## Several Sign-Ins at Once
By default the session holds one `omniauth.origin` and `omniauth.params`,
so if a user starts a second sign-in before the first finishes (in another
tab, for example), the first one's callback gets the second one's origin
and params.

A strategy can keep them apart when its provider sends a value from the
request phase back to the callback, such as OAuth 2.0's `state`. Its
request phase calls `remember_sign_in` with that value, and it overrides
`callback_sign_in_key` to return the value from the callback:

```ruby
def request_phase
  state = SecureRandom.hex(24)
  remember_sign_in(state)
  redirect authorize_url(state)
end

def callback_sign_in_key
  request.params['state']
end
```

OmniAuth then stores the origin and params of the latest 5 sign-ins under
their keys in `session['omniauth.sign_ins']`, and gives each callback its
own. It still sets `omniauth.origin` and `omniauth.params` in the session
for the latest sign-in, and falls back to them when a callback's key isn't
remembered.

## Resources
The [OmniAuth Wiki](https://github.com/omniauth/omniauth/wiki) has
actively maintained in-depth documentation for OmniAuth. It should be
your first stop if you are wondering about a more in-depth look at
OmniAuth, how it works, and how to use it.

## Supported Ruby Versions
OmniAuth requires Ruby 2.5 or later and Rack 2.2.8 or later, including Rack 3.
It is tested on Ruby 2.5 through 4.0, with both Rack 2 and Rack 3, and on JRuby
and TruffleRuby.

## Versioning
This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

    spec.add_dependency 'omniauth', '~> 2.2'

[semver]: https://semver.org/
[pvc]: https://guides.rubygems.org/patterns/#pessimistic-version-constraint

## License
Copyright (c) 2010-2026 Michael Bleigh and Intridea, Inc. See [LICENSE][] for
details.

[license]: LICENSE.md
