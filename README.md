# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Heroku proof of concept

heroku buildpacks:add jtschoonhoven/heroku-buildpack-tor

// to get the .onion name
heroku ps:exec --dyno=tor.1 'cat "/app/hidden_service/hostname"'

