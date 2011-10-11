# OmniAuth Identity

The OmniAuth Identity gem provides a way for applications to utilize a
traditional login/password based authentication system without the need
to give up the simple authentication flow provided by OmniAuth. Identity
is designed on purpose to be as featureless as possible: it provides the
basic construct for user management and then gets out of the way.

## Usage

You use `oa-identity` just like you would any other OmniAuth provider: as a
Rack middleware. The basic setup for a email/password authentication would
look something like this:

    use OmniAuth::Builder do
      provider :identity, :fields => [:email]
    end

Next, you need to create a model (called `Identity` by default) that will be
able to persist the information provided by the user. Luckily for you, there
are pre-built models for popular ORMs that make this dead simple. You just
need to subclass the relevant class:

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

Please see http://github.com/adambair/simple-identity for a working example 
of an `oa-identity` implementation.

## Custom Auth Model

To use a class other than the default, specify the <tt>:model</tt> option to a
different class.

    use OmniAuth::Builder do
      provider :identity, :fields => [:email], :model => MyCustomClass
    end

## Customizing Registration Failure

To use your own custom registration form, create a form that POSTs to
'/auth/identity/register' with 'password', 'password_confirmation', and your
other fields.

    <%= form_tag '/auth/identity/register' do |f| %>
      <h1>Create an Account</h1>
      <%= text_field_tag :email %>
      <%= password_field_tag, :password %>
      <%= password_field_tag, :password_confirmation %>
      <%= submit_tag %>
    <% end %>

Beware not to nest your form parameters within a namespace. This strategy
looks for the form parameters at the top level of the post params. If you are
using [simple\_form](https://github.com/plataformatec/simple_form), then you
can avoid the params nesting by specifying <tt>:input_html</tt>.

    <%= simple_form_for @identity, :url => '/auth/identity/register' do |f| %>
      <h1>Create an Account</h1>
      <%# specify :input_html to avoid params nesting %>
      <%= f.input :email, :input_html => {:name => 'email'} %>
      <%= f.input :password, :as => 'password', :input_html => {:name => 'password'} %>
      <%= f.input :password_confirmation, :label => "Confirm Password", :as => 'password', :input_html => {:name => 'password_confirmation'} %>
      <button type='submit'>Sign Up</button>
    <% end %>

Next you'll need to let OmniAuth know what action to call when a registration
fails. In your OmniAuth configuration, specify any valid rack endpoint in the
<tt>:on_failed_registration</tt> option.

    use OmniAuth::Builder do
      provider :identity,
        :fields => [:email],
        :on_failed_registration => UsersController.action(:new)
    end

For more information on rack endpoints, check out [this
introduction](http://library.edgecase.com/Rails/2011/01/04/rails-routing-and-rack-endpoints.html)
and
[ActionController::Metal](http://rubydoc.info/docs/rails/ActionController/Metal)

## Examples

  * Rails 3.1 ActiveRecord - http://github.com/adambair/simple-identity
