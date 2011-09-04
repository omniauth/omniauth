# OmniAuth: Standardized Multi-Provider Authentication

**NOTICE:** This documentation and code is toward OmniAuth 1.0 in which
each provider will become its own separate gem. If you're looking for
the current released version, please visit [OmniAuth 0.3 Stable
Branch](https://github.com/intridea/omniauth/tree/0-3-stable).

## Structural Changes Coming in 1.0

In version 1.0, the `omniauth` gem will become simply the underlying
framework upon which authentication strategies can be built. That means
where once users would put `gem 'omniauth'` into their Gemfile and be
finished, now each provider will have a separate gem (e.g.
`oa-twitter`).

This change will bring about better code, faster releases, and hopefully
an even more vibrant provider landscape. For more on the rationale of
the change, see [this issue](https://github.com/intridea/omniauth/issues/451).

## Technical Changes Coming in 1.0

### The AuthHash Class

In the past, OmniAuth has provided a simple hash of authentication
information. In 1.0, the returned data will be an AuthHash, a special
kind of hash that has extra properties special to OmniAuth. In addition,
the auth hash schema will be changing slightly. More on that soon.

### Universal Options

In 1.0, it will be possible to set certain configuration options that
will then apply to all providers. This will make certain things easier.

### Simpler Dynamic Workflow

To date, the workflow for "dynamic" providers (being able to change them
at runtime) has been somewhat difficult. We will be re-evaluating this
process and making sure it's as good as it can be.

### Declarative Provider Authorship

We hope to provide a more declarative provider authorship system that
will make it both easier to write and easier to test strategies. Much of
this may have to be implemented in "aggregate" strategy providers such
as OAuth and OAuth2, but stay tuned for more on this.

### Testing, Testing, Testing!

OmniAuth 1.0 will be strongly tested and solid. Because we can release
it one piece at a time (starting with the core gem and expanding out
into the other provider gems) we will be able to maintain much higher
code quality and the project will generally be more manageable.

## Stay Tuned!

OmniAuth 1.0 is a work in progress. We will keep the community updated
about progress as we have more information. Thanks!

# <a name="license">License</a>
OmniAuth is released under the MIT License.
