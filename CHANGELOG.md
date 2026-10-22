# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 2.0.0](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Entries before 2.2.0 were reconstructed from the Git history, GitHub
releases, and RubyGems.org. Dates are when each version was published
to RubyGems.org. Before 1.0.0, `omniauth` was a meta-gem bundling the
`oa-*` gems (oa-core, oa-oauth, oa-openid, and so on), which were
versioned together, so those entries cover all of them.

## [Unreleased]

## [2.3.1] - 2026-10-22

### Fixed
- `remember_sign_in` no longer raises `KeyError` when called outside the request phase, before `omniauth.params` is stored, as when a provider gem's specs call `authorize_params` directly.

## [2.3.0] - 2026-10-22

### Added
- Let strategies keep the origin and params of several sign-ins in progress at once, for example in several tabs, so each callback gets its own instead of the latest sign-in's. A strategy opts in by calling `remember_sign_in` in its request phase with a value the provider sends back, such as OAuth 2.0's state, and overriding `callback_sign_in_key`. The latest 5 are stored in `session['omniauth.sign_ins']`, and `omniauth.origin` and `omniauth.params` still hold the latest one. See [the README](README.md#several-sign-ins-at-once). ([omniauth-oauth2#195](https://github.com/omniauth/omniauth-oauth2/issues/195))

### Changed
- The gem no longer includes `CHANGELOG.md`, which was about half its size. Its `changelog_uri` links to the changelog on GitHub.

## [2.2.0] - 2026-10-22

### Added
- Add a `full_host` option for each strategy, as a string or a proc that takes the Rack env. It takes precedence over `OmniAuth.config.full_host`. ([#835](https://github.com/omniauth/omniauth/issues/835))
- Ship RBS type signatures for OmniAuth in `sig/`.
- Document the Rack env keys OmniAuth sets, CSRF protection, sending `origin` as a form field, and how `SameSite` session cookies affect the callback in the README. ([#909](https://github.com/omniauth/omniauth/issues/909), [#1075](https://github.com/omniauth/omniauth/pull/1075), [#1048](https://github.com/omniauth/omniauth/pull/1048), [#1149](https://github.com/omniauth/omniauth/issues/1149))
- Add this changelog.

### Changed
- `omniauth.params` now includes params posted to the request phase's form, not just its query string, so they survive the POST-only request phase introduced in 2.0. The `authenticity_token` param is never included (see CVE-2017-18076 under 1.3.2). If your request form posts other fields, they now appear in `omniauth.params` and are stored in the session until the callback. ([#975](https://github.com/omniauth/omniauth/issues/975))
- `OmniAuth::Builder` builds its middleware stack on the first request and reuses it, instead of rebuilding every strategy on every request. Providers added after the first request are ignored. ([#1083](https://github.com/omniauth/omniauth/issues/1083), [#970](https://github.com/omniauth/omniauth/issues/970))
- `Strategy#call` sends a request that isn't on the strategy's request or callback path straight to the app, instead of duplicating the strategy for it. It still duplicates it in test mode, with an `other_phase`, with path lambdas, or when the strategy overrides how `#call!` dispatches. Methods patched directly onto `OmniAuth::Strategy`, rather than overridden in a subclass, aren't detected, so a patched `#call!` no longer runs for requests outside the strategy's paths. ([#1172](https://github.com/omniauth/omniauth/pull/1172))
- Require Ruby 2.5 or later (was 2.2). ([#1167](https://github.com/omniauth/omniauth/pull/1167))
- Require Rack 2.2.8 or later (was 2.2.3), rack-protection 2.2.0 or later, and hashie 3.5.2 or later (was 3.4.6).
- The gem now contains only `lib`, `sig`, the license, the README, the changelog, and the security policy.

### Fixed
- Run the `before_callback_phase` hook for mocked failures in test mode, as for real callbacks. ([#1043](https://github.com/omniauth/omniauth/issues/1043), [#1171](https://github.com/omniauth/omniauth/pull/1171))
- Recognize callback paths with a format suffix, such as `/auth/:provider/callback.json`. ([#618](https://github.com/omniauth/omniauth/issues/618), [#1170](https://github.com/omniauth/omniauth/pull/1170))
- Don't fail callbacks when the app defines a method named `uid`, `info`, `credentials`, or `extra` on `Object`. ([#898](https://github.com/omniauth/omniauth/issues/898), [#1169](https://github.com/omniauth/omniauth/pull/1169))
- Don't add a calculated `name` to the info hash subsets returned by `slice`, `except`, `select`, and `reject`. ([#892](https://github.com/omniauth/omniauth/issues/892), [#1168](https://github.com/omniauth/omniauth/pull/1168))
- Collapse repeated slashes in the request path, as Rails routing does, so `//auth/:provider` from a misconfigured proxy reaches the strategy. ([#1079](https://github.com/omniauth/omniauth/issues/1079))
- Avoid "instance variable not initialized" warnings on Ruby before 3.0.

### Security
- Guard against forged hosts in callback URLs. Unless a `full_host` is set, OmniAuth builds the callback URL it sends to the provider from the request's `Host`, `X-Forwarded-Host`, or `Forwarded` header, which a client can forge. The new `OmniAuth.config.allowed_hosts`, a list of strings and regexps, makes the request and callback phases fail with `invalid_host` unless the request's host matches one of them. Until `full_host` or `allowed_hosts` is set, the request phase logs a warning. The README's `full_host` example, which copied the `Host` header, is fixed. ([GHSA-m27g-v28p-f9fx](https://github.com/omniauth/omniauth/security/advisories/GHSA-m27g-v28p-f9fx), CVE-2026-63183)
- Run `request_validation_phase` before writing `omniauth.params` to the session, so a cross-site POST rejected by the authenticity check can no longer store attacker-controlled params. ([#1162](https://github.com/omniauth/omniauth/pull/1162))

## [2.1.4] - 2025-10-01

### Added
- Add an `after_request_phase` hook, settable with `OmniAuth.config.after_request_phase` or in the builder block, that runs after the request phase (including in test mode). ([#1147](https://github.com/omniauth/omniauth/pull/1147))

### Changed
- Add `logger` as a runtime dependency, because Ruby 3.5 no longer bundles it as a default gem. ([#1142](https://github.com/omniauth/omniauth/pull/1142))

## [2.1.3] - 2025-02-27

### Fixed
- Keep an `omniauth.origin` value already set in the Rack env in test mode instead of replacing it with the session value. The session's `omniauth.origin` is still cleared. ([#1134](https://github.com/omniauth/omniauth/pull/1134))
- Fix `full_host` with versions of the `uri` library that no longer define `URI::ABS_URI`. ([#1136](https://github.com/omniauth/omniauth/pull/1136))

## [2.1.2] - 2023-12-19

### Added
- Add a `:method` option to `OmniAuth::Form`. It defaults to `'post'`. ([#1106](https://github.com/omniauth/omniauth/pull/1106))

### Changed
- Make the `developer` strategy's form submit to its callback with GET, so it works with the setup described in the README. ([#1106](https://github.com/omniauth/omniauth/pull/1106))

### Fixed
- Fix loading OmniAuth on JRuby with Rack 2 by requiring `delegate` first. ([#1122](https://github.com/omniauth/omniauth/pull/1122))

## [2.1.1] - 2023-01-20

### Fixed
- Fix a `NoMethodError` in `callback_path` (and `request_path`) when you call it on a strategy before it has handled a request. ([#1092](https://github.com/omniauth/omniauth/pull/1092), [#1080](https://github.com/omniauth/omniauth/issues/1080))

## [2.1.0] - 2022-04-13

### Added
- Support Ruby 3.0 and later. `Builder#provider` now passes options to the strategy as keyword arguments. ([#1064](https://github.com/omniauth/omniauth/pull/1064))

### Changed
- **Breaking:** Require Rack 2.2.3 or later, and remove the `< 3` upper bound on Rack. ([#1064](https://github.com/omniauth/omniauth/pull/1064))

## [2.0.4] - 2021-04-07

### Fixed
- Log the GET warning only for requests to a strategy's request path, not for every request that passes through the middleware. ([#1041](https://github.com/omniauth/omniauth/pull/1041))

## [2.0.3] - 2021-02-18

### Fixed
- Re-raise errors that come from the downstream app (for example through `call_app!` in `other_phase`) instead of sending them to `on_failure`. Errors raised by the authentication phases still go to `on_failure`. ([#1035](https://github.com/omniauth/omniauth/pull/1035), [#1030](https://github.com/omniauth/omniauth/issues/1030))

## [2.0.2] - 2021-02-02

### Fixed
- In test mode, verify the authenticity token only on the request phase, as a real request does, instead of on every request that passes through the middleware. ([#1033](https://github.com/omniauth/omniauth/pull/1033), [#1032](https://github.com/omniauth/omniauth/issues/1032))

## [2.0.1] - 2021-01-16

### Fixed
- Allow a configured instance of `OmniAuth::AuthenticityTokenProtection` to be used as the `request_validation_phase`, e.g. `OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)`. ([#1027](https://github.com/omniauth/omniauth/pull/1027))

## [2.0.0] - 2021-01-11

### Added
- Add a configurable `request_validation_phase`, which runs before `before_request_phase`. It defaults to `OmniAuth::AuthenticityTokenProtection`, which uses rack-protection to check the authenticity token and raises `OmniAuth::AuthenticityError` (sent to `on_failure` as `:authenticity_error`) when the check fails. Rails apps need a Rails-aware validator instead, such as omniauth-rails_csrf_protection 1.0. ([#1010](https://github.com/omniauth/omniauth/pull/1010))
- Log a warning on every request when `allowed_request_methods` includes `:get`. Set `OmniAuth.config.silence_get_warning = true` to turn it off. ([#1010](https://github.com/omniauth/omniauth/pull/1010))
- Add `rack-protection` as a runtime dependency. ([#1010](https://github.com/omniauth/omniauth/pull/1010))

### Changed
- **Breaking:** Allow only POST for the request phase by default (`allowed_request_methods` is now `[:post]`), and require a valid authenticity token. Replace links to `/auth/:provider` with forms that POST and include the token. ([#1010](https://github.com/omniauth/omniauth/pull/1010), [#960](https://github.com/omniauth/omniauth/issues/960))
- **Breaking:** Rescue `StandardError`s raised during the options, request, callback and other phases and pass them to `on_failure` (by default a redirect to `/auth/failure`) instead of letting them propagate. ([#689](https://github.com/omniauth/omniauth/pull/689))
- **Breaking:** Look up strategies given to `provider` as a symbol only under `OmniAuth::Strategies`, not in ancestor namespaces, so `provider :my_provider` no longer finds a top-level `::MyProvider`. ([#962](https://github.com/omniauth/omniauth/pull/962))
- **Breaking:** Redirect failures to the failing strategy's `path_prefix` (e.g. `/external/failure`) instead of the global `path_prefix`. ([#931](https://github.com/omniauth/omniauth/pull/931))
- **Breaking:** Include `SCRIPT_NAME` in the default request and callback paths and match against the full request path, so apps mounted under a sub-path (e.g. `/super/auth/:provider`) work. ([#903](https://github.com/omniauth/omniauth/pull/903))
- Escape the `message` query parameter in the failure redirect. ([#689](https://github.com/omniauth/omniauth/pull/689))
- Log the "phase initiated" and setup messages at debug level instead of info. ([#949](https://github.com/omniauth/omniauth/pull/949))

### Fixed
- Fix errors when running with `--enable-frozen-string-literal`. ([#917](https://github.com/omniauth/omniauth/pull/917), [#1014](https://github.com/omniauth/omniauth/pull/1014))
- Copy a strategy's options when it is cloned as well as when it is `dup`ed, so the middleware no longer mutates shared state and is thread-safe. ([#1015](https://github.com/omniauth/omniauth/pull/1015))
- Evaluate a strategy's `credentials` and `extra` once each when building the auth hash, instead of twice. ([#1000](https://github.com/omniauth/omniauth/pull/1000))
- Fix `OmniAuth::Utils.camelize` with `false` as the second argument when ActiveSupport is not loaded. ([#995](https://github.com/omniauth/omniauth/pull/995))

### Security
- CVE-2015-9284: Protect the request phase from cross-site request forgery by allowing only POST and checking the authenticity token by default. ([#1010](https://github.com/omniauth/omniauth/pull/1010), [#809](https://github.com/omniauth/omniauth/pull/809), [#960](https://github.com/omniauth/omniauth/issues/960))

## [1.9.2] - 2022-08-18

### Security
- CVE-2020-36599: Escape the error message key in the redirect to the failure endpoint so a crafted message can't inject content into the `Location` header. This backports the fix that shipped in 2.0.0.

## [1.9.1] - 2020-03-02

### Changed
- Remove the upper bound on `hashie`, which allows Hashie 4.x. The requirement is now `>= 3.4.6`. ([#977](https://github.com/omniauth/omniauth/pull/977), [#979](https://github.com/omniauth/omniauth/pull/979))

### Removed
- Remove `OmniAuth::Builder#rack14?`, `OmniAuth::Builder#rack2?` and the `OmniAuth::Builder` initializer workaround for Rack versions older than 1.4, which the `rack` requirement already excluded. ([#977](https://github.com/omniauth/omniauth/pull/977))

## [1.9.0] - 2018-12-14

### Changed
- **Breaking:** Require Ruby 2.2 or later. ([#950](https://github.com/omniauth/omniauth/pull/950))
- Allow `hashie` 3.6. The requirement is now `>= 3.4.6, < 3.7.0`. ([#943](https://github.com/omniauth/omniauth/pull/943))

## [1.8.1] - 2017-12-28

### Security
- CVE-2017-17042: Require `yard` >= 0.9.11 in the development Gemfile. The gem's runtime dependencies are unchanged. ([#924](https://github.com/omniauth/omniauth/pull/924))

## [1.8.0] - 2017-12-27

### Changed
- Internal maintenance only.

## [1.7.1] - 2017-10-02

### Fixed
- Honor the `origin_param` option in test mode's mock request phase. ([#913](https://github.com/omniauth/omniauth/pull/913))

## [1.7.0] - 2017-09-28

### Added
- Add the `origin_param` strategy option to rename the `origin` request parameter (default `'origin'`), or set it to `false` to stop storing `omniauth.origin`. ([#912](https://github.com/omniauth/omniauth/pull/912))

## [1.6.1] - 2017-02-18

### Removed
- Stop storing request headers in the session as `omniauth.headers`, which had been added in 1.6.0, because it caused `ActionDispatch::Cookies::CookieOverflow` errors. ([#889](https://github.com/omniauth/omniauth/pull/889))

## [1.6.0] - 2017-02-17

### Added
- Store the request phase's HTTP headers in the session and expose them in the callback phase as `env['omniauth.headers']`. ([#806](https://github.com/omniauth/omniauth/pull/806))

### Changed
- Loosen the `hashie` requirement to `>= 3.4.6, < 3.6.0` to work around performance problems in Hashie 3.5.x. ([#887](https://github.com/omniauth/omniauth/pull/887))
- In test mode, run the mock request phase only for methods in `allowed_request_methods`, and pass other requests through to the app. ([#779](https://github.com/omniauth/omniauth/pull/779))
- Improve performance by reading options with `Hashie::Mash#[]` and memoizing `default_options`. ([#777](https://github.com/omniauth/omniauth/pull/777), [#778](https://github.com/omniauth/omniauth/pull/778))

### Fixed
- Set `omniauth.params` when a mocked authentication fails in test mode. ([#812](https://github.com/omniauth/omniauth/pull/812))
- Wrap `info` in an `InfoHash` only when it is assigned a Hash, so that non-Hash values such as `nil` are kept. ([#848](https://github.com/omniauth/omniauth/pull/848))
- Fix Ruby warnings about uninitialized instance variables. ([#850](https://github.com/omniauth/omniauth/pull/850))

## [1.5.0] - 2017-02-11

### Changed
- **Breaking:** Require Ruby 2.1.9 or later. Ruby 1.9.3, Ruby 2.0 and JRuby in 1.9 mode are no longer supported. ([#883](https://github.com/omniauth/omniauth/pull/883), [#884](https://github.com/omniauth/omniauth/pull/884))
- **Breaking:** Require `hashie` `~> 3.5.0`. ([#883](https://github.com/omniauth/omniauth/pull/883))
- Require `rack` >= 1.6.2. ([#881](https://github.com/omniauth/omniauth/pull/881))

### Fixed
- Silence `Hashie::Mash` key-conflict warnings with Hashie's `disable_warnings` when it is available, which replaces the temporary fix from 1.4.2. ([#882](https://github.com/omniauth/omniauth/pull/882))

## [1.4.3] - 2017-12-18

### Security
- Require `rack` >= 1.6.2 to avoid known vulnerabilities in older Rack releases. ([#881](https://github.com/omniauth/omniauth/pull/881))

## [1.4.2] - 2017-02-11

### Fixed
- Fix a regression with newer Hashie releases by always overriding the `Hashie::Mash` warning logger instead of calling `disable_warnings`. ([#880](https://github.com/omniauth/omniauth/pull/880))

## [1.4.1] - 2017-02-08

### Changed
- Internal maintenance only.

## [1.4.0] - 2017-02-06

### Fixed
- Silence the warnings that Hashie 3.5.0 and later log when a key conflicts with a method name. `AuthHash`, `InfoHash` and `Strategy::Options` now inherit from the new `OmniAuth::KeyStore`. ([#874](https://github.com/omniauth/omniauth/pull/874))
- Load the OpenID input background image in the default form CSS over HTTPS. ([#876](https://github.com/omniauth/omniauth/pull/876))

### Removed
- Drop support for Ruby 1.8.7. ([#877](https://github.com/omniauth/omniauth/pull/877))

## [1.3.2] - 2017-01-17

### Security
- CVE-2017-18076: Store only query string parameters (`request.GET`) in `omniauth.params`. POST body parameters such as `authenticity_token` were previously saved in the session and exposed in the callback phase. ([#867](https://github.com/omniauth/omniauth/pull/867))

## [1.3.1] - 2015-12-20

### Changed
- Allow Rack 2. The `rack` requirement is now `>= 1.0, < 3`.

## [1.3.0] - 2015-12-20

### Added
- Detect Rack 2 in `OmniAuth::Builder`, in preparation for Rack 2 support. ([#820](https://github.com/omniauth/omniauth/pull/820))

### Changed
- Reduce object allocations per request by memoizing `request_path`, `callback_path` and `current_path` on the strategy. ([#774](https://github.com/omniauth/omniauth/pull/774))

### Fixed
- Stop `OmniAuth.config.add_mock` from mutating the hash passed to it. ([#828](https://github.com/omniauth/omniauth/pull/828))
- Duplicate a strategy's options when the strategy is duplicated, so that copies no longer share and mutate the same options. ([#829](https://github.com/omniauth/omniauth/pull/829))
- Set `omniauth.origin` when a mocked authentication fails in test mode. ([#795](https://github.com/omniauth/omniauth/pull/795))

## [1.2.2] - 2014-07-09

### Changed
- Allow `hashie` 3.x (`>= 1.2, < 4`). ([#748](https://github.com/omniauth/omniauth/pull/748))
- Stop signing the gem with a certificate.

## [1.2.1] - 2014-01-16

### Changed
- Require `rack` `~> 1.0`.

### Fixed
- Package `lib/omniauth/form.css` in the gem again; 1.2.0 left it out and failed to load.

## [1.2.0] - 2014-01-16 [YANKED]

### Added
- Add `before_request_phase`, `before_callback_phase` and `before_options_phase` hooks, configurable through `OmniAuth.config` or `OmniAuth::Builder`. ([#667](https://github.com/omniauth/omniauth/pull/667))
- Add `OmniAuth.config.failure_raise_out_environments` to choose which `RACK_ENV`s raise failures instead of redirecting (default `['development']`). ([#686](https://github.com/omniauth/omniauth/pull/686))
- Let strategies keep their default option values for positional `args` that the caller leaves out. ([#701](https://github.com/omniauth/omniauth/pull/701))

### Changed
- Redirect to the full `callback_url` from the request phase in test mode. ([#699](https://github.com/omniauth/omniauth/pull/699))
- Change the name in the default mock auth hash from "Bob Example" to "Example User".
- Lower the required RubyGems version to 1.3.5.

### Fixed
- Report the current path as `callback_path` when a callable `:callback_path` option matches the request. ([#676](https://github.com/omniauth/omniauth/pull/676))
- Fix `full_host` raising on Rack 1.3 when the request has no scheme.

## [1.1.4] - 2013-04-08

### Changed
- Allow `hashie` 2.x (`>= 1.2, < 3`).

### Fixed
- Fix `Strategy.configure` when its block returns `nil` or `false`. ([#672](https://github.com/omniauth/omniauth/pull/672))
- Send `Content-Type: text/html` with forms rendered by `OmniAuth::Form`.
- Remove Ruby warnings about uninitialized instance variables and redefined methods.

## [1.1.3] - 2013-02-14

### Fixed
- Detect HTTPS in `full_host` from `HTTPS`, `X-Forwarded-SSL`, `X-Forwarded-Scheme` and `X-Forwarded-Proto` headers on every supported Rack version. ([#664](https://github.com/omniauth/omniauth/pull/664), [#663](https://github.com/omniauth/omniauth/issues/663))

## [1.1.2] - 2013-02-08

### Changed
- Detect HTTPS in `full_host` with `Rack::Request#ssl?`. ([#647](https://github.com/omniauth/omniauth/pull/647))
- Sign the gem with a certificate and declare the MIT license in the gemspec.

## [1.1.1] - 2012-08-24

### Fixed
- Fix a thread-safety issue in `OmniAuth::Builder` by adding the app to the middleware stack at initialization instead of on each call. ([#609](https://github.com/omniauth/omniauth/pull/609))
- Keep `omniauth.params` from the request phase in test mode. ([#610](https://github.com/omniauth/omniauth/pull/610))

## [1.1.0] - 2012-04-13

### Added
- Add logging through `OmniAuth.config.logger` (defaults to STDOUT) and `Strategy#log`. ([#583](https://github.com/omniauth/omniauth/issues/583))
- Add `options` to `OmniAuth::Builder` to share options across all its providers. ([#584](https://github.com/omniauth/omniauth/issues/584))
- Accept a callable for `:request_path` and `:callback_path` to match paths dynamically. ([#585](https://github.com/omniauth/omniauth/issues/585))
- Add `origin` and `strategy` query params to the default failure redirect. ([#592](https://github.com/omniauth/omniauth/pull/592), [#569](https://github.com/omniauth/omniauth/issues/569))

### Changed
- Move the default `on_failure` handler into `OmniAuth::FailureEndpoint`, which raises the error when `RACK_ENV` is `development` instead of redirecting to `/auth/failure`. ([#578](https://github.com/omniauth/omniauth/issues/578))
- Stop calling the underlying app during the request phase in test mode. ([#586](https://github.com/omniauth/omniauth/pull/586))

### Fixed
- Declare UTF-8 in forms rendered by `OmniAuth::Form`. ([#550](https://github.com/omniauth/omniauth/issues/550))

## [1.0.3] - 2012-03-06

### Fixed
- Use `https` in `full_host` when the `X-Forwarded-Proto` header is `https`. ([#572](https://github.com/omniauth/omniauth/pull/572))
- Return the app's finished Rack response from the request phase in test mode. ([#576](https://github.com/omniauth/omniauth/pull/576))

## [1.0.2] - 2012-01-17

### Added
- Support Rack 1.4 in `OmniAuth::Builder` while staying compatible with Rack 1.3. ([#561](https://github.com/omniauth/omniauth/pull/561), [#562](https://github.com/omniauth/omniauth/issues/562))

### Changed
- Make the default mock auth an `OmniAuth::AuthHash` instead of a plain hash. ([#564](https://github.com/omniauth/omniauth/pull/564))

### Fixed
- Prefix the default failure redirect with `SCRIPT_NAME`. ([#554](https://github.com/omniauth/omniauth/pull/554))
- Skip the default "Connect" button in `OmniAuth::Form` when a custom button was added. ([#551](https://github.com/omniauth/omniauth/pull/551))

## [1.0.1] - 2011-11-25

### Added
- Raise a `LoadError` that suggests installing the `omniauth-<provider>` gem when `provider` can't find a strategy. ([#536](https://github.com/omniauth/omniauth/issues/536))

### Fixed
- Pass params from the request phase to `env['omniauth.params']` in the callback again. ([#544](https://github.com/omniauth/omniauth/pull/544))
- Put the name in the default mock auth hash under `info`, matching real auth hashes. ([#540](https://github.com/omniauth/omniauth/pull/540))

## [1.0.0] - 2011-11-02

### Added
- Add the `developer` strategy, a form-based strategy for development without a real provider.
- Add the `:skip_info` option (`true` or a lambda taking the uid) to skip fetching user info. ([#292](https://github.com/omniauth/omniauth/issues/292))
- Add the `:form` option to render a custom form (a Rack endpoint, or `true` to call through to the app) in the request phase.
- Respond to `OPTIONS` requests on auth paths with the allowed methods. ([#374](https://github.com/omniauth/omniauth/pull/374), [#370](https://github.com/omniauth/omniauth/issues/370))

### Changed
- **Breaking:** Make the `omniauth` gem contain only the core framework. Each provider strategy now lives in its own gem (such as `omniauth-oauth`, `omniauth-oauth2`, `omniauth-openid`, `omniauth-twitter`, `omniauth-facebook`), which you must add to your Gemfile. Pin `omniauth` to `~> 0.3.2` to stay on the old API.
- **Breaking:** Adopt the 1.0 Auth Hash Schema: rename the `user_info` key to `info`, and return the auth hash as an `OmniAuth::AuthHash` (a `Hashie::Mash`). `info.name` falls back to the first and last name, nickname or email.
- **Breaking:** Replace the Strategy API. Strategies declare defaults with `option`, positional arguments with `args`, and auth hash data with `uid`, `info`, `credentials` and `extra` blocks; options are a `Hashie::Mash`, and the strategy's name comes from the `:name` option instead of an argument to `initialize`.
- **Breaking:** Stop calling through to the app at the start of the request phase to let it render a form; use the `:form` option instead.
- **Breaking:** Load the library with `require 'omniauth'` instead of `require 'omniauth/core'`, and register special camelizations with `OmniAuth.config.add_camelization` instead of `OmniAuth::Utils::CAMELIZE_SPECIAL`.
- **Breaking:** Make `OmniAuth::Form.build` take an options hash instead of a title. ([#520](https://github.com/omniauth/omniauth/issues/520))
- Depend on `hashie` `~> 1.2`. ([#495](https://github.com/omniauth/omniauth/issues/495))

### Removed
- **Breaking:** Remove the `oa-core`, `oa-oauth`, `oa-openid`, `oa-enterprise`, `oa-basic` and `oa-more` gems and all strategies they contained.

## [0.3.2] - 2011-10-20

### Changed
- Internal maintenance only. This release contains the changes from the yanked 0.3.1.

## [0.3.1] - 2011-10-20 [YANKED]

### Added
- OAuth: Add MySpace and XING strategies. ([#501](https://github.com/omniauth/omniauth/pull/501), [#488](https://github.com/omniauth/omniauth/pull/488))
- OAuth: Support Facebook's `signed_request` parameter. ([#469](https://github.com/omniauth/omniauth/pull/469))
- OAuth: Let `google_oauth2` take a custom route name. ([#511](https://github.com/omniauth/omniauth/pull/511))
- OAuth: Pass `:authorize_params` to Google's request token call. ([#508](https://github.com/omniauth/omniauth/pull/508))
- OAuth: Add the email address to XING's `user_info`. ([#515](https://github.com/omniauth/omniauth/pull/515))
- Enterprise: Let the SAML strategy take a custom name. ([#476](https://github.com/omniauth/omniauth/pull/476))
- Enterprise: Add SAML assertion attributes to the `extra` hash. ([#497](https://github.com/omniauth/omniauth/pull/497))

### Fixed
- OAuth: Let `OAuth2::Error` from OAuth2 strategies reach `on_failure` instead of being re-raised as a `RuntimeError`. ([#509](https://github.com/omniauth/omniauth/pull/509), [#513](https://github.com/omniauth/omniauth/pull/513))
- OAuth: Fix the Gowalla, 37signals and Salesforce strategies. ([#506](https://github.com/omniauth/omniauth/pull/506), [#514](https://github.com/omniauth/omniauth/pull/514), [#505](https://github.com/omniauth/omniauth/pull/505))

## [0.3.0] - 2011-09-22

### Added
- OAuth: Add OAuth strategies for Blogger, Dropbox, Flattr, Flickr, Google Health (and its sandbox) and Orkut. ([#350](https://github.com/omniauth/omniauth/pull/350), [#389](https://github.com/omniauth/omniauth/pull/389), [#417](https://github.com/omniauth/omniauth/pull/417), [#396](https://github.com/omniauth/omniauth/pull/396))
- OAuth: Add OAuth2 strategies for AngelList, Cobot, Glitch, Google (`google_oauth2`), Mailchimp, Viadeo, WePay and Windows Live ID. ([#443](https://github.com/omniauth/omniauth/pull/443), [#403](https://github.com/omniauth/omniauth/pull/403), [#385](https://github.com/omniauth/omniauth/pull/385), [#342](https://github.com/omniauth/omniauth/pull/342), [#439](https://github.com/omniauth/omniauth/pull/439), [#432](https://github.com/omniauth/omniauth/pull/432), [#348](https://github.com/omniauth/omniauth/pull/348), [#425](https://github.com/omniauth/omniauth/pull/425))
- OpenID: Add the Google Hybrid (OpenID + OAuth) strategy. ([#394](https://github.com/omniauth/omniauth/pull/394), [#408](https://github.com/omniauth/omniauth/pull/408))
- Enterprise: Add the SAML strategy. ([#445](https://github.com/omniauth/omniauth/pull/445))
- More: Add the Last.fm strategy. ([#406](https://github.com/omniauth/omniauth/pull/406))
- Core: Expose the params passed to the request phase as `env['omniauth.params']` in the callback.
- Core: Keep query string params when redirecting in test mode. ([#413](https://github.com/omniauth/omniauth/pull/413))
- OAuth: Let Twitter take a `:name` option, let Hyves take request token options, and add Salesforce's `issued_at`, `signature` and `refresh_token` to the credentials. ([#414](https://github.com/omniauth/omniauth/pull/414), [#444](https://github.com/omniauth/omniauth/pull/444))

### Changed
- OAuth: **Breaking:** Require `oauth2` `~> 0.5.0` and `faraday` `~> 0.7.3`; OAuth2 strategies now use the auth code flow and rescue `OAuth2::Error`, so custom strategies built on oauth2 0.4 need updating.
- OAuth: Move SoundCloud and Yammer to OAuth2. ([#416](https://github.com/omniauth/omniauth/pull/416), [#463](https://github.com/omniauth/omniauth/pull/463))
- OAuth: Request HTTPS scopes from Google by default, and only the userinfo scopes from `google_oauth2`. ([#346](https://github.com/omniauth/omniauth/pull/346), [#412](https://github.com/omniauth/omniauth/pull/412), [#424](https://github.com/omniauth/omniauth/pull/424))
- Require `multi_xml` `~> 0.4.0`, `nokogiri` `~> 1.5.0` and `addressable` `~> 2.2.6`.

### Removed
- More: **Breaking:** Remove the Flickr strategy from oa-more in favor of the new OAuth-based one in oa-oauth. ([#417](https://github.com/omniauth/omniauth/pull/417))

### Fixed
- OAuth: Fail with `:service_unavailable` on SSL errors and 5xx responses when fetching the request token, and with `:session_expired` when the OAuth session is missing in the callback. ([#427](https://github.com/omniauth/omniauth/pull/427), [#429](https://github.com/omniauth/omniauth/pull/429), [#382](https://github.com/omniauth/omniauth/pull/382), [#381](https://github.com/omniauth/omniauth/pull/381))
- OAuth: Fix the Facebook, Foursquare, Goodreads, Instagram, LinkedIn, Taobao, Tsina and Vkontakte strategies. ([#405](https://github.com/omniauth/omniauth/pull/405), [#430](https://github.com/omniauth/omniauth/pull/430), [#473](https://github.com/omniauth/omniauth/pull/473), [#426](https://github.com/omniauth/omniauth/pull/426), [#378](https://github.com/omniauth/omniauth/pull/378), [#436](https://github.com/omniauth/omniauth/pull/436), [#435](https://github.com/omniauth/omniauth/pull/435), [#410](https://github.com/omniauth/omniauth/pull/410))
- OAuth: Fix the email scope requested by `google_oauth2`. ([#452](https://github.com/omniauth/omniauth/pull/452), [#468](https://github.com/omniauth/omniauth/pull/468))
- OpenID: Treat an empty identifier from the form as missing. ([#447](https://github.com/omniauth/omniauth/pull/447))
- Enterprise: Use the `:base` option in LDAP when given. ([#448](https://github.com/omniauth/omniauth/pull/448))
- Core: Stop relying on ActiveSupport's `stringify_keys` in `add_mock`. ([#411](https://github.com/omniauth/omniauth/pull/411))

## [0.2.6] - 2011-05-20

### Added
- Add new strategies. OAuth: Mail.ru, Plurk, Taobao. OpenID: Steam. More: Draugiem, IGN. ([#296](https://github.com/omniauth/omniauth/pull/296), [#303](https://github.com/omniauth/omniauth/pull/303), [#333](https://github.com/omniauth/omniauth/pull/333), [#339](https://github.com/omniauth/omniauth/pull/339), [#341](https://github.com/omniauth/omniauth/pull/341))
- Core: Add a `:header_info` option to `OmniAuth::Form` for adding extra HTML to the form's `<head>`. ([#303](https://github.com/omniauth/omniauth/pull/303))
- OAuth: Include the refresh token and token expiry in the Gowalla auth hash's `extra`. ([#307](https://github.com/omniauth/omniauth/pull/307))
- OAuth: Add `birth_date` to the Vkontakte `user_info`. ([#321](https://github.com/omniauth/omniauth/pull/321), [#322](https://github.com/omniauth/omniauth/pull/322))

### Changed
- **Breaking:** OAuth: Rename the Vkontakte `user_info` key `firstname` to `first_name`. ([#323](https://github.com/omniauth/omniauth/pull/323))
- OAuth: Take the Facebook `nickname` from the user's `username` instead of the end of their profile URL. ([#317](https://github.com/omniauth/omniauth/pull/317))

### Fixed
- OAuth: Fix the LinkedIn strategy, which broke when it switched from Nokogiri to MultiXML, and fix LinkedIn users with exactly one URL. ([#297](https://github.com/omniauth/omniauth/pull/297), [#300](https://github.com/omniauth/omniauth/pull/300), [#316](https://github.com/omniauth/omniauth/pull/316))
- OAuth: Refresh an expired OAuth 2.0 access token with the refresh token instead of requesting a new one, and include `refresh_token` in `credentials` for expiring tokens. ([#314](https://github.com/omniauth/omniauth/pull/314), [#331](https://github.com/omniauth/omniauth/pull/331), [#328](https://github.com/omniauth/omniauth/issues/328))
- OAuth: Fail with `:timeout` instead of raising when an OAuth 2.0 provider times out. ([#313](https://github.com/omniauth/omniauth/pull/313))
- Include `SCRIPT_NAME` in the OAuth 2.0 callback URL and in the test mode redirect. ([#312](https://github.com/omniauth/omniauth/pull/312), [#329](https://github.com/omniauth/omniauth/pull/329))
- OAuth: Honor the `:iframe` option when OAuth 1.0 strategies redirect. ([#305](https://github.com/omniauth/omniauth/pull/305))
- OAuth: Stop the Google strategy from adding the contacts scope a second time when it is given as an `https` URL. ([#299](https://github.com/omniauth/omniauth/pull/299))
- OAuth: Handle empty city and country responses from Vkontakte. ([#302](https://github.com/omniauth/omniauth/pull/302))
- Enterprise: Parse nested CAS user attributes correctly. ([#324](https://github.com/omniauth/omniauth/pull/324))

## [0.2.5] - 2011-04-29

### Added
- Add new strategies. OAuth: Douban, NetEase Weibo (`T163`), QQ (`Qzone`), Rdio, Renren, Sina Weibo (`Tsina`), Sohu Weibo (`Tsohu`), Tencent Weibo (`Tqq`), Yammer. More: Yupoo.
- OAuth: Add `public_profile_url` to the LinkedIn `user_info`.

### Changed
- OAuth: Parse XML with MultiXML instead of Nokogiri, and require `multi_json ~> 1.0.0` and `multi_xml ~> 0.2.2`.
- Require `net-ldap ~> 0.2.2` (Enterprise), `rack-openid ~> 1.3.1` and `ruby-openid-apps-discovery ~> 1.2.0` (OpenID).
- Replace the `Omniauth::VERSION` constant with `OmniAuth::Version::STRING`.
- OAuth: Use the Twitter `screen_name` as `name` when the user has no name. ([#289](https://github.com/omniauth/omniauth/issues/289))

### Fixed
- Core: Match request and callback paths case-insensitively for strategies whose names contain capital letters. ([#273](https://github.com/omniauth/omniauth/issues/273))
- Core: Set `env['omniauth.strategy']` only on that strategy's own paths, so the setup phase no longer falls through to the last-defined strategy. ([#259](https://github.com/omniauth/omniauth/issues/259))
- OAuth: Make the Foursquare `:mobile` and `:sign_in` options take effect, and fill `email` with the user's email address instead of their Twitter handle. ([#293](https://github.com/omniauth/omniauth/pull/293))
- Enterprise: Fix LDAP authentication with Rails 2.3. ([#291](https://github.com/omniauth/omniauth/pull/291))

### Security
- Enterprise: Reject a blank password in the LDAP strategy. When `bind_dn` and `password` were configured, a user could log in with a valid username and no password. ([#294](https://github.com/omniauth/omniauth/pull/294))

## [0.2.4] - 2011-04-22

### Changed
- OAuth: Require `oauth2 ~> 0.4.1`. ([#275](https://github.com/omniauth/omniauth/pull/275))
- `oa-core` no longer declares a runtime dependency on `rack`.
- Enterprise: Pin `addressable` to 2.2.4.

## [0.2.3] - 2011-04-21

### Added
- OAuth: Add Vkontakte strategy.

### Changed
- OAuth: Relax the `multi_json` requirement to `>= 0.0.5`. ([#270](https://github.com/omniauth/omniauth/issues/270), [#271](https://github.com/omniauth/omniauth/issues/271))

## [0.2.2] - 2011-04-16

### Added
- OAuth: Add Teambox and Tumblr strategies.

### Changed
- OAuth: Require `oauth2 ~> 0.3.0` and `faraday ~> 0.6.1` to fix SSL errors. ([#260](https://github.com/omniauth/omniauth/issues/260))

### Removed
- **Breaking:** Core: Remove the deprecated `Password` strategy.

### Fixed
- Core: Make `OmniAuth::Strategy#inspect` short, which fixes very slow Rails error pages. ([#243](https://github.com/omniauth/omniauth/issues/243))
- Enterprise: Fix a `NameError` for `Net` in the CAS service ticket validator. ([#262](https://github.com/omniauth/omniauth/issues/262))
- OAuth: Treat malformed API responses as a failure instead of raising.

## [0.2.1] - 2011-04-05

### Added
- OAuth: Add Salesforce strategy. ([#233](https://github.com/omniauth/omniauth/pull/233))
- OAuth: Add an `:authorize_params` option to OAuth 1.0 strategies, and a Twitter `:force_login` option.

### Changed
- OAuth: Require `oauth2 ~> 0.2.0`. ([#255](https://github.com/omniauth/omniauth/issues/255))
- More: Return Flickr `user_info` as `nickname` and `name` instead of the raw user data.
- Set `omniauth.origin` in test mode.

### Fixed
- Core: Run the setup phase only on OmniAuth request and callback paths. ([#231](https://github.com/omniauth/omniauth/issues/231))
- Core: Keep `omniauth.origin` available when authentication fails. ([#227](https://github.com/omniauth/omniauth/issues/227))

## [0.2.0] - 2011-03-11

### Added
- Add the `oa-more` gem, with Flickr and Windows Live strategies, and add it to the `omniauth` meta-gem.
- Add new strategies. OAuth: Bitly, Dailymile, Doit.im, Evernote, Goodreads, Google, Hyves, Instagram, Instapaper, Miso, Mixi, Netflix, SmugMug, TradeMe, TypePad, Vimeo, Yahoo, YouTube, and a generic xAuth strategy. ([#205](https://github.com/omniauth/omniauth/pull/205), [#213](https://github.com/omniauth/omniauth/issues/213), [#222](https://github.com/omniauth/omniauth/pull/222))
- Core: Add test mode with `OmniAuth.config.test_mode`, `mock_auth` and `add_mock` for integration testing.
- Core: Store the page the user came from (or an `origin` parameter) and expose it as `env['omniauth.origin']` in the callback. ([#211](https://github.com/omniauth/omniauth/pull/211), [#218](https://github.com/omniauth/omniauth/issues/218))
- Core: Add a `:setup` option to every strategy for configuring it per request. ([#188](https://github.com/omniauth/omniauth/pull/188))
- Core: Call through to the app on the request path first, so the app can handle or configure the request phase. ([#62](https://github.com/omniauth/omniauth/issues/62))
- Core: Add per-strategy `:path_prefix`, `:request_path` and `:callback_path` options. ([#54](https://github.com/omniauth/omniauth/issues/54))
- Core: Accept a block when initializing a strategy, as an alternative to arguments. ([#56](https://github.com/omniauth/omniauth/issues/56))
- Core: Add `OmniAuth.config.full_host` (a String or Proc) to override the host in callback URLs. ([#101](https://github.com/omniauth/omniauth/issues/101))
- Core: Add `OmniAuth.config.allowed_request_methods` to limit which HTTP methods start the request phase. ([#153](https://github.com/omniauth/omniauth/issues/153))
- Core: Add an `:iframe` option that redirects with JavaScript, for Facebook iframe apps.
- Add `oa-core.rb`, `oa-oauth.rb` and similar files so each gem can be required by its name without Bundler. ([#193](https://github.com/omniauth/omniauth/issues/193))
- OAuth: Support OAuth 1.0 as well as 1.0a.
- OAuth: Add Twitter `:sign_in` and LinkedIn `:sign_in` options, and use LinkedIn's authenticate flow by default. ([#29](https://github.com/omniauth/omniauth/pull/29), [#40](https://github.com/omniauth/omniauth/pull/40), [#180](https://github.com/omniauth/omniauth/pull/180))
- OAuth: Let the Google strategy take a custom `:scope`. ([#171](https://github.com/omniauth/omniauth/issues/171))
- OAuth: Log in with an existing Facebook JavaScript SDK session cookie when present.
- OAuth: Add email and image to Facebook `user_info`, and public profile URL and nickname to LinkedIn `user_info`. ([#81](https://github.com/omniauth/omniauth/pull/81))
- Enterprise: Add a CAS `:disable_ssl_verification` option and an LDAP `:name_proc` option.

### Changed
- **Breaking:** Core: The `on_failure` proc now receives only `env`. Read the failure reason from `env['omniauth.error.type']` and the strategy from `env['omniauth.error.strategy']`. ([#55](https://github.com/omniauth/omniauth/issues/55))
- **Breaking:** Core: Raise `OmniAuth::NoSessionError` when no `rack.session` is available.
- **Breaking:** OAuth: Rewrite the Foursquare strategy to use OAuth 2.0.
- Core: Strip trailing slashes from request and callback paths, and match them case-insensitively. ([#148](https://github.com/omniauth/omniauth/issues/148))
- Core: Include `SCRIPT_NAME` and the query string in the callback URL.
- Enterprise: Switch LDAP to a redirect flow, which fixes `InvalidAuthenticityToken` errors in Rails. ([#145](https://github.com/omniauth/omniauth/issues/145))
- OAuth: Require `oauth2 ~> 0.1.1`.

### Removed
- **Breaking:** Core: Remove the deprecated `env['rack.auth']` and `env['rack.auth.error']`. Use `env['omniauth.auth']` and `env['omniauth.error']`.

### Fixed
- OAuth: Fix the OAuth 1.0a flow so it sends `oauth_verifier`.
- OAuth: Fail instead of raising on timeouts, JSON parse errors and 5xx responses from the access token endpoint. ([#158](https://github.com/omniauth/omniauth/issues/158), [#217](https://github.com/omniauth/omniauth/pull/217))
- OAuth: Use string session keys so OAuth works with Rails sessions. ([#113](https://github.com/omniauth/omniauth/issues/113))
- OAuth: Strip the query string from Facebook's callback URL to avoid a URI error. ([#192](https://github.com/omniauth/omniauth/issues/192))
- OAuth: Set `uid` for Identi.ca and `name` for LinkedIn. ([#98](https://github.com/omniauth/omniauth/issues/98), [#104](https://github.com/omniauth/omniauth/issues/104))
- OpenID: Return a blank name instead of `" "` when the provider sends no name. ([#103](https://github.com/omniauth/omniauth/issues/103))
- Enterprise: Strip the ticket from the CAS service URL and handle gzip-compressed CAS responses. ([#162](https://github.com/omniauth/omniauth/issues/162))
- Core: Fix `fail!` to work with the default `on_failure`. ([#175](https://github.com/omniauth/omniauth/issues/175))

## [0.1.6] - 2010-10-25

### Added
- OAuth: Add Meetup and SoundCloud strategies. ([#66](https://github.com/omniauth/omniauth/pull/66))

### Changed
- OAuth: Require `oauth2 ~> 0.1.0`. ([#70](https://github.com/omniauth/omniauth/issues/70), [#71](https://github.com/omniauth/omniauth/issues/71))
- OpenID: Require `rack-openid ~> 1.2.0`.

### Fixed
- OpenID: Read Attribute Exchange values correctly, so `name`, `first_name` and `last_name` are filled in for Google.
- OAuth: Fix TripIt URL encoding on Ruby 1.9.

## [0.1.5] - 2010-10-19

### Added
- OAuth: Add TripIt and Dopplr strategies. ([#60](https://github.com/omniauth/omniauth/pull/60))

### Changed
- OAuth: Change the default Gowalla scope to `read`.
- OAuth: Request Facebook user data with an English `Accept-Language` header.
- Enterprise: Use `pyu-ruby-sasl` for LDAP DIGEST-MD5 binds.

### Fixed
- OAuth: Detect OAuth 2.0 callback errors given only as `error_reason`, as Facebook sends them. ([#58](https://github.com/omniauth/omniauth/issues/58))
- OpenID: Stop deleting the `:name` option, which changed the strategy's paths. ([#61](https://github.com/omniauth/omniauth/issues/61))

## [0.1.4] - 2010-10-12

### Added
- OAuth: Add Identi.ca strategy. ([#45](https://github.com/omniauth/omniauth/pull/45))
- OpenID: Add an `:identifier` option to fix the OpenID provider, such as Google or Yahoo. ([#47](https://github.com/omniauth/omniauth/pull/47))

### Fixed
- OAuth: Fail with `:invalid_credentials` when an OAuth 2.0 provider sends an `error` to the callback. ([#48](https://github.com/omniauth/omniauth/issues/48))
- OAuth: Pass strategy options such as `:scope` through to the OAuth 2.0 authorize URL.
- OpenID: Try normal discovery before Google Apps discovery, so Google is no longer queried on every OpenID request. ([#50](https://github.com/omniauth/omniauth/issues/50))
- Core: Add a `Content-Type` header to the default failure redirect.

## [0.1.3] - 2010-10-11

### Added
- OAuth: Add Gowalla strategy.
- Core: Add `configure` and `on_failure` to `OmniAuth::Builder`.
- Core: Expose the exception behind a failure as `env['omniauth.error']`.
- Enterprise: Add `name` to LDAP `user_info`.

### Changed
- OAuth: Use Twitter's `/oauth/authenticate` endpoint so returning users are not asked to authorize again.

### Deprecated
- Core: Deprecate `env['rack.auth']` and `env['rack.auth.error']` in favor of `env['omniauth.auth']` and `env['omniauth.error']`. ([#37](https://github.com/omniauth/omniauth/issues/37))

### Fixed
- OpenID: Fix an `ArgumentError` when building the auth hash. ([#42](https://github.com/omniauth/omniauth/issues/42))
- OAuth: Treat `OAuth2::AccessDenied` as `:invalid_credentials`.

## [0.1.2] - 2010-10-06

### Added
- OpenID: Show a domain form for Google Apps when no domain is given.

### Fixed
- Set `env['rack.auth']` in the OAuth, OpenID, HTTP Basic and Password strategies, which still set only `params['auth']`.

## [0.1.1] - 2010-10-04

### Added
- Enterprise: Add LDAP strategy.

### Changed
- `require 'omniauth'` now loads the Enterprise strategies.
- OAuth: Remove `screen_name` from Twitter `user_info`. Use `nickname`.

## [0.1.0] - 2010-10-01

### Added
- OAuth: Add Foursquare strategy.

### Changed
- **Breaking:** Core: Provide the auth hash only in `env['rack.auth']`, no longer in `params['auth']`.
- **Breaking:** OpenID: Rename the identifier parameter from `identifier` to `openid_url`. ([#13](https://github.com/omniauth/omniauth/issues/13))

## [0.0.5] - 2010-09-01

### Added
- Core: Also set the auth hash in `env['rack.auth']`, alongside `params['auth']`.

## [0.0.4] - 2010-08-16

### Added
- Enterprise: Add the `oa-enterprise` gem with a CAS strategy.
- OAuth: Add 37signals strategy using OAuth 2.0.
- OpenID: Add Google Apps strategy.
- Core: Add `OmniAuth::Test` helpers for testing strategies.

### Changed
- Load strategies with `autoload`.
- Use `multi_json` instead of `json`, so apps can choose their JSON library.
- Pin dependency versions, including `rack ~> 1.1`, `oauth ~> 0.4.0`, `oauth2 ~> 0.0.10`, `rest-client ~> 1.6.0` and `rack-openid ~> 1.1.1`.
- OpenID: Request first and last name as required Attribute Exchange attributes.

### Removed
- **Breaking:** Basic: Remove the HTTP Basic Campfire and Basecamp strategies in favor of the 37signals OAuth 2.0 strategy.
- OpenID: Remove the broken Google strategy.

## [0.0.3] - 2010-05-01

### Added
- Basic: Add the `oa-basic` gem with HTTP Basic, Campfire and Basecamp strategies.
- Core: Add `OmniAuth::Form` and the `form_css` setting for built-in login forms.
- OpenID: Show an identifier form when no identifier is given, instead of failing.

### Changed
- Release all gems with the same version number.

## [0.0.1] - 2010-04-29

### Added
- Initial release, made up of `oa-core` (`OmniAuth::Builder` and a Password strategy), `oa-oauth` (OAuth and OAuth 2.0 with Twitter, LinkedIn, Facebook and GitHub) and `oa-openid` (OpenID).

[Unreleased]: https://github.com/omniauth/omniauth/compare/v2.3.1...HEAD
[2.3.1]: https://github.com/omniauth/omniauth/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/omniauth/omniauth/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/omniauth/omniauth/compare/v2.1.4...v2.2.0
[2.1.4]: https://github.com/omniauth/omniauth/compare/v2.1.3...v2.1.4
[2.1.3]: https://github.com/omniauth/omniauth/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/omniauth/omniauth/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/omniauth/omniauth/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/omniauth/omniauth/compare/v2.0.4...v2.1.0
[2.0.4]: https://github.com/omniauth/omniauth/compare/v2.0.3...v2.0.4
[2.0.3]: https://github.com/omniauth/omniauth/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/omniauth/omniauth/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/omniauth/omniauth/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/omniauth/omniauth/compare/v1.9.1...v2.0.0
[1.9.2]: https://github.com/omniauth/omniauth/compare/v1.9.1...v1.9.2
[1.9.1]: https://github.com/omniauth/omniauth/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/omniauth/omniauth/compare/v1.8.1...v1.9.0
[1.8.1]: https://github.com/omniauth/omniauth/compare/v1.8.0...v1.8.1
[1.8.0]: https://github.com/omniauth/omniauth/compare/v1.7.1...v1.8.0
[1.7.1]: https://github.com/omniauth/omniauth/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/omniauth/omniauth/compare/v1.6.1...v1.7.0
[1.6.1]: https://github.com/omniauth/omniauth/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/omniauth/omniauth/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/omniauth/omniauth/compare/v1.4.3...v1.5.0
[1.4.3]: https://github.com/omniauth/omniauth/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/omniauth/omniauth/compare/2dccbb560ffb...v1.4.2
[1.4.1]: https://github.com/omniauth/omniauth/compare/v1.4.0...2dccbb560ffb
[1.4.0]: https://github.com/omniauth/omniauth/compare/v1.3.2...v1.4.0
[1.3.2]: https://github.com/omniauth/omniauth/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/omniauth/omniauth/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/omniauth/omniauth/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/omniauth/omniauth/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/omniauth/omniauth/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/omniauth/omniauth/compare/v1.1.4...v1.2.0
[1.1.4]: https://github.com/omniauth/omniauth/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/omniauth/omniauth/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/omniauth/omniauth/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/omniauth/omniauth/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/omniauth/omniauth/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/omniauth/omniauth/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/omniauth/omniauth/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/omniauth/omniauth/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/omniauth/omniauth/compare/v0.3.2...v1.0.0
[0.3.2]: https://github.com/omniauth/omniauth/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/omniauth/omniauth/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/omniauth/omniauth/compare/v0.2.6...v0.3.0
[0.2.6]: https://github.com/omniauth/omniauth/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/omniauth/omniauth/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/omniauth/omniauth/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/omniauth/omniauth/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/omniauth/omniauth/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/omniauth/omniauth/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/omniauth/omniauth/compare/v0.1.6...v0.2.0
[0.1.6]: https://github.com/omniauth/omniauth/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/omniauth/omniauth/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/omniauth/omniauth/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/omniauth/omniauth/compare/b2cd9c8f33c8...v0.1.3
[0.1.2]: https://github.com/omniauth/omniauth/compare/v0.1.1...b2cd9c8f33c8
[0.1.1]: https://github.com/omniauth/omniauth/compare/cf202fe6a257...v0.1.1
[0.1.0]: https://github.com/omniauth/omniauth/compare/b60b6ce8921e...cf202fe6a257
[0.0.5]: https://github.com/omniauth/omniauth/compare/v0.0.4...b60b6ce8921e
[0.0.4]: https://github.com/omniauth/omniauth/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/omniauth/omniauth/compare/91533b7f45bd...v0.0.3
[0.0.1]: https://github.com/omniauth/omniauth/tree/91533b7f45bd
