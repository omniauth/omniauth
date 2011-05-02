# OmniAuth Identity

The OmniAuth Identity gem provides a way for applications to utilize a
traditional login/password based authentication system without the need
to give up the simple authentication flow provided by OmniAuth. Identity
is designed on purpose to be as featureless as possible: it provides the
basic construct for user management and then gets out of the way.

## Usage

You use `oa-identity` just like you would any other OmniAuth provider:
as a Rack middleware. The basic setup would look something like this:

    use OmniAuth::Builder do
      provider :identity
    end

Next, you need to create a model (called `Identity by default`) that will 
be able to persist the information provided by the user. Luckily for you, 
there are pre-built models for popular ORMs that make this dead simple. You 
just need to subclass the relevant class:

    class Identity < OmniAuth::Identity::Models::ActiveRecord
      # Add whatever you like!
    end

Adapters are provided for `ActiveRecord` and `MongoMapper` and are
autoloaded on request (but not loaded by default so no dependencies are
injected).

Once you've got an Identity persistence model and the strategy up and
running, you can point users to `/auth/identity` and it will request
that they log in or give them the opportunity to sign up for an account.
Once they have authenticated with their identity, OmniAuth will call
through to `/auth/identity/callback` with the same kinds of information
it would had the user authenticated through an external provider.
Simple!
