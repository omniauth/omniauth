# Getting your environment set up for OmniAuth:

## RVM

Setup an `.rvmrc`

    rvm gemset use omniauth

If you have not set the create flag, you will need to create the gemset manually.

## Bootstrap gems

You need the `bundler` and `term-ansicolor` gems to get started

    gem install bundler
    gem install term-ansicolor

## Install all dependencies

There is a rake task that loads all the required gems

    rake dependencies:install

## Run the tests

If all is well, you should have a green run

    rake spec

## Start writing code!
