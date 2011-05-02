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

Next, you need to create a model that will be able to persist the
information provided by the user. By default, this model should be a
class called `Identity` and should respond to the following API:

    Identity.create(
      :name => 'x', 
      :password => 'y', 
      :confirm_password => 'y'
    )

    identity = Identity.authenticate('key', 'password')
      # => Identity instance if correct
      # => false if incorrect

    identity.user_info # => {'name' => '...', 'nickname' => '...'}
    identity.uid       # => must be unique to the application

To make things easier, you can inherit your model from the ones provided
for popular ORMs which will automatically provide the default setup
necessary. For example:

    class Identity < OmniAuth::Identity::Model::ActiveRecord
      login_key :nickname
    end
