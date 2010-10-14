## Shield

# A simple authentication framework for use with a basic Rack application.
# It doesn't try to be generic and instead has the following assertions:

# 1. You use [Ohm][ohm] for your persistence layer.
# 2. That your app has some form of a Helper plugin system.

## Usage

# The fastest way to get started with `Shield` is to use it as a [Sinatra][sin]
# extension on top of your main application.

# We simply have to require sinatra, shield, and [Ohm][ohm].
require "sinatra/base"
require "shield"
require "ohm"

# We then define a `User` class on the top-level namespace:
class User < Shield::User
end

# Our sinatra application can be a classic style, but for this example,
# we'll use the more modular style extending from `Sinatra::Base`.
class App < Sinatra::Base
  # One very very important detail to remember is that you need to
  # have session support for all of Shield to work.
  enable :sessions

  # Now for the main highlight: This line simply does two things:
  # 1. It adds `Shield::Helpers` to your Sinatra app's helpers.
  # 2. It adds `Shield::Login` as a middleware for your application.
  register Shield

  # This is a normal sinatra route. No authentication is needed here.
  get "/public" do
    "Public"
  end

  # This is a private sinatra route, which we enforce using
  # `ensure_authenticated`. This method comes from `Shield::Helpers` along
  # with some other helper methods:
  #
  # 1. `current_user`         - ain't this the standard nowadays?
  # 2. `logged_in?`           - simple sugar to verify if the user is logged in.
  # 3. `ensure_authenticated` - as shown here.
  # 4. `redirect_to_stored`   - redirects to the previous url the user was
  #                             trying to access prior to authenticating.
  get "/private" do
    ensure_authenticated

    "Private"
  end
end

# If this file was run directly i.e. ruby README.rb.
if __FILE__ == $0
  # For the purposes of this quick script, let's create a User. You'll use that
  # to quickly verify that you can indeed login to the application.
  if User.all.size == 0
    User.create(:email => "quentin@test.com",
                :password => "password",
                :password_confirmation => "password")
  end

  # Let Sinatra take the stage.
  App.run!
end

# [ohm]: http://ohm.keyvalue.org
# [sin]: http://sinatrarb.com