# OmniAuth::Identity

`OmniAuth::Identity` brings a traditional e-mail/login based sign in
flow to OmniAuth without sacrificing the simplicity and pattern
employed by OmniAuth's external authenticating brethren. It allows
users to create "identities" that consist of a user's basic info,
a login key, and a password.

## Installation

To install omniauth as a suite of gems:

    gem install omniauth

To install just the login/password flow in the "identity" gem:

    gem install oa-identity

## Usage

You can use `OmniAuth::Identity` just like any other provider: that's
the whole point!

    use OmniAuth::Builder do
      provider :identity, :key => :email, :attributes => [:name, :email, :location]
    end

Now your users will be able to create or sign into an identity by 
visiting `/auth/identity`. Once they have done so, your application
will receive a callback at `/auth/identity/callback` just like it
would with any other OmniAuth strategy.

## ORMs

`OmniAuth::Identity` supports multiple ORMs:

* ActiveRecord
* MongoMapper

By default, it will try to detect which if any of the ORMs your app
is using in the order specified above. You can also explicitly set
the ORM by making this call before you instantiate the middleware:

    require 'omniauth/identity/orm/ormname'

Where `ormname` is the same as the **gem name** of the ORM you would
like to use.

To implement a custom ORM, it's quite simple. You simply need to define
the `OmniAuth::Identity` class such that it adheres to the interface set 
forth in `OmniAuth::Identity::Interface`.    
