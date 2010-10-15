## Introduction

# [Sinatra][sin] is possibly the most underrated, yet emulated framework
# throughout the whole web development community. So far it has been
# ported to [Lua][mercury], [PHP][frank], [Scala][scalatra] (and I guess
# a couple of other more I haven't heard about). The same model of mapping
# URLs to handlers have also emerged, some of which include [Flask][flask]
# in Python, [Compojure][compojure] in Clojure, [Snap][snap] in Haskell
# and [Sammy][sammy] in Javascript.

# [Ohm][ohm] is a very lightweight Object mapping library using Redis as the
# backend. Like Sinatra, it is very simple and has inspired several closely
# similar libraries like [Nohm][nohm], [Johm][johm] and [Redisco][redisco].
#
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
# [sin-ohm]: http://github.com/cyx/shield/tree/master/examples/sinatra-ohm.rb
# [nohm]: http://github.com/maritz/nohm
# [johm]: http://github.com/xetorthio/johm
# [redisco]: http://github.com/iamteem/redisco

## Walkthrough

# _A note before we start:_ You can [view the source][sin-ohm] of this
# entire example.

$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

# For our example, we'll need `sinatra`, `ohm`, `shield` and `haml`.
require "sinatra"
require "ohm"
require "shield"
require "haml"

### The User model

# We declare our `User` class to have only the absolute minimum (which is
# realistic and can be used in the real world).
class User < Ohm::Model
  # `Shield::Model` adds an `authenticate` method to your model. You'll
  # need to implement `fetch` yourself, or you can check out some of the
  # pre-made solutions in [shield-contrib][shield-contrib].
  extend Shield::Model

  # In [Ohm][ohm], you declare all your attributes (different from the usual
  # ActiveRecord or Sequel style).
  #
  # Here we just declare our `email` and `crypted_password` fields. We also
  # make sure that we can search users by their `email` by declaring it as an
  # `index`.
  attribute :email
  index :email

  attribute :crypted_password

  # The `fetch` protocol is actually really simple to implement. Here we just
  # find the first user by `email`.
  def self.fetch(email)
    find(:email => email).first
  end

  # This isn't required in any way by `Shield` but this is the most simple and
  # straightforward way to do password storage.
  def password=(password)
    write_local(:crypted_password, Shield::Password.encrypt(password))

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
  # 2. A `request` method (which maps to Rack::Request) exists.
  # 3. A `session` method exists.
  # 4. A `User` class exists, with a `User::[]` method that finds any user by
  #    its ID.
  helpers Shield::Helpers

  # Like any web application that maintains some kind of state, we'll need
  # sessions for this sinatra application.
  enable :sessions

  # We'll also enable `:inline_templates` for this example to make this a
  # one-file ruby application. (See the __END__ at the end).
  enable :inline_templates

  # Nothing to see here except that we provide a link to `/login`.
  get "/" do
    "Welcome to the example app. <a href='/login'>Login</a>"
  end

  # The dashboard is protected via the `ensure_authenticated` method.
  # We also add a `logout` link.
  get "/dashboard" do
    ensure_authenticated

    "And we're in! <a href='/logout'>Logout</a>"
  end

  # Our dead-simple login form. Check the @@login section below to see
  # the actual `haml` file.
  get "/login" do
    haml :login
  end

  # The crux of the login process appears here. We make use of the
  # `login` method provided by `Shield::Helpers`.
  post "/login" do
    if login(params[:username], params[:password])
      redirect "/dashboard"
    else
      @error = "Wrong Username and/or Password combination."
      haml :login
    end
  end

  # Finally, a simple logout route which uses `logout` provided by
  # `Shield::Helpers`.
  get "/logout" do
    logout
    redirect "/"
  end
end

# For the purposes of this demo, we'll create a simple user with
# the following credentials.
USER = "quentin@test.com"
PASS = "happiness"

User.create(:email => USER, :password => PASS)

# This is the usual sinatra idiom, which basically means that
# you can run it by simply doing `ruby examples/sinatra-ohm.rb`.
App.run! if __FILE__ == $0

### Running this example in your machine

# It's actually quite simple:
#
#     git clone git://github.com/cyx/shield.git
#     [sudo] gem install sinatra
#     [sudo] gem install haml
#     [sudo] gem install ohm
#
#     redis-server
#
#     cd shield
#     ruby examples/sinatra-ohm.rb

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
