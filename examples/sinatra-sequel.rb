## Introduction

# [Sinatra][sin] is possibly the most underrated, yet emulated framework
# throughout the whole web development community. So far it has been
# ported to [Lua][mercury], [PHP][frank], [Scala][scalatra] (and I guess
# a couple of other more I haven't heard about). The same model of mapping
# URLs to handlers have also emerged, some of which include [Flask][flask]
# in Python, [Compojure][compojure] in Clojure, [Snap][snap] in Haskell
# and [Sammy][sammy] in Javascript.

# [Sequel][sequel] is a lightweight database toolkit for Ruby. One of the most
# enticing things about Sequel is that it boasts a really pluggale architecture,
# and that is evident through its heavy use of plugins.

# [sin]: http://sinatrarb.com
# [mercury]: http://github.com/nrk/mercury
# [frank]: http://github.com/brucespang/Frank.php
# [scalatra]: http://www.scalatra.org/
# [compojure]: http://github.com/weavejester/compojure
# [flask]: http://flask.pocoo.org/
# [snap]: http://snapframework.com
# [sammy]: http://code.quirkey.com/sammy/
# [ohm]: http://ohm.keyvalue.org
# [shield-contrib]: http://github.com/cyx/shield-contrib
# [sin-s]: http://github.com/cyx/shield/tree/master/examples/sinatra-sequel.rb
# [sequel]: http://sequel.rubyforge.org
# [shield]: http://github.com/cyx/shield

## Walkthrough

# _A note before we start: You can [view the source][sin-s] of this_
# _entire example._
$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

# For our example, we'll need `sinatra`, `sequel`, `shield` and `haml`.
require "sinatra"
require "sequel"
require "shield"
require "haml"

# This is just the standard way of configuring your [Sequel][sequel]
# connection. Here, we use an in-memory Sequel database for the purposes of
# our demo.
DB = Sequel.sqlite

### The User Model

# Our `User` model will need only the `schema` plugin for our minimalistic
# example.
class User < Sequel::Model
  plugin :schema

  # All code here is mostly boilerplate just to create the table and define
  # the schema. The only relation it has to [Shield][shield] is that the
  # columns are what we would normally expect on our `User` model.
  unless table_exists?
    set_schema do
      primary_key :id
      text :email
      text :crypted_password
    end

    create_table
  end

  # This marks the start of our `Shield::Model` integration. This gives us a
  # `User::authenticate` method which accepts a `username` and `password`.
  extend Shield::Model

  # In order to complete the implementation of `User::authenticate`, we simply
  # have to define our strategy of fetching a `User` given the login name,
  # which for our demo is the `email` of the `User`.
  def self.fetch(email)
    first(:email => email)
  end

  # This isn't required in any way by `Shield` but this is the most simple and
  # straightforward way to do password storage.
  def password=(password)
    self.crypted_password = Shield::Password.encrypt(password)

    @password = password
  end
end

### Using it with a Sinatra app

# Now we declare our [Sinatra][sin] application in the more modular way by
# extending `Sinatra::Base`.
class App < Sinatra::Base
  # `Shield::Helpers` is actually just a simple module with the following
  # assumptions:
  #
  # 1. A `redirect` method exists.
  # 2. A `request` method (which maps to `Rack::Request`) exists.
  # 3. A `session` method exists.
  # 4. Your model class, e.g. `User` has a `[]` method (i.e. `User::[]`)
  #    that finds any user by its ID.
  helpers Shield::Helpers

  # Like any web application that maintains some kind of state, we'll need
  # sessions for this sinatra application.
  enable :sessions

  # We'll also enable `:inline_templates` for this example to make this a
  # one-file ruby application. (See the `__END__` at the end).
  enable :inline_templates

  # Nothing to see here except that we provide a link to `/login`.
  get "/" do
    "Welcome to the example app. <a href='/login'>Login</a>"
  end

  # The dashboard is protected via the `ensure_authenticated` method.
  # We also add a `logout` link.
  get "/dashboard" do
    ensure_authenticated(User)

    "And we're in! <a href='/logout'>Logout</a>"
  end

  # Our dead-simple login form. Check the `@@login` section below to see
  # the actual `haml` file.
  get "/login" do
    haml :login
  end

  # The crux of the login process appears here. We make use of the
  # `login` method provided by `Shield::Helpers`.
  post "/login" do
    if login(User, params[:username], params[:password])
      redirect "/dashboard"
    else
      @error = "Wrong Username and/or Password combination."
      haml :login
    end
  end

  # Finally, a simple logout route which uses `logout` provided by
  # `Shield::Helpers`.
  get "/logout" do
    logout(User)
    redirect "/"
  end

  # Up until now, most authentication solutions made in Ruby had used the
  # `current_user` method in the context of controllers and views. We can
  # easily emulate that here by defining it like so:
  helpers do
    def current_user
      authenticated(User)
    end
  end
end

# For the purposes of this demo, we'll create a simple user with
# the following credentials.
USER = "quentin@test.com"
PASS = "happiness"

User.create(:email => USER, :password => PASS)

# This is the usual sinatra idiom, which basically means that
# you can run it by simply doing `ruby examples/sinatra-sequel.rb`.
App.run! if __FILE__ == $0

### Running this example in your machine

# It's actually quite simple:
#
#     git clone git://github.com/cyx/shield.git
#     [sudo] gem install sinatra
#     [sudo] gem install haml
#     [sudo] gem install sequel sqlite3-ruby
#
#     cd shield
#     ruby examples/sinatra-sequel.rb

__END__

@@ login

%h1 Login
%h2 (to login, just use #{USER} / #{PASS})

%form(action="/login" method="post")
  %fieldset
    - if @error
      %p(style="color: red")= @error

    %label
      %span Username
      %input(type="text" name="username" value="#{params[:username]}")

    %label
      %span Password
      %input(type="password" name="password")

  %fieldset.buttons
    %button(type="submit")
      %span Login