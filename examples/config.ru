SHIELD_ROOT = File.expand_path("../", File.dirname(__FILE__))

$:.unshift(File.join(SHIELD_ROOT, "lib"))

require "cuba"
require "shield"

class User < Struct.new(:id)
  extend Shield::Model

  def self.[](id)
    User.new(1) unless id.to_s.empty?
  end

  def self.authenticate(username, password)
    User.new(1001) if username == "quentin" && password == "password"
  end
end

# Cuba.use Rack::Session::Cookie

Cuba.define do
  extend Shield::Helpers

  persist_session!

  on "login" do
    on get do
      res.write("<form action='/login' method='post'>" +
               "<input type='text' name='username'>" +
               "<input type='password' name='password'>" +
               "<input type='submit' name='submit'>" +
               "<input type='checkbox' name='remember_me' value=1></form>")
    end

    on post, param("username"), param("password") do |u, p|
      if login(User, u, p, req[:remember_me])
        res.redirect "/secured"
      else
        session[:error] = "Bad login"
        res.redirect "/login"
      end
    end
  end

  on "logout" do
    logout(User)

    res.redirect "/login"
  end

  on "secured" do
    ensure_authenticated(User, "/login")

    res.write "Secure: 42"
  end
end

run Cuba