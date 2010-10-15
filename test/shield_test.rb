require File.expand_path("helper", File.dirname(__FILE__))

class User < Struct.new(:id)
  extend Shield::Model

  def self.[](id)
    User.new(1) unless id.to_s.empty?
  end

  def self.authenticate(username, password)
    User.new(1001) if username == "quentin" && password == "password"
  end
end

class Context
  def initialize(path)
    @path = path
  end

  def session
    @session ||= {}
  end

  class Request < Struct.new(:fullpath)
  end

  def request
    Request.new(@path)
  end

  def redirect(redirect = nil)
    @redirect = redirect if redirect
    @redirect
  end

  include Shield::Helpers
end

setup do
  Context.new("/events/1")
end

test "ensure_authenticated when logged out" do |context|
  context.ensure_authenticated(User)
  assert "/events/1" == context.session[:return_to]
  assert "/login" == context.redirect
end

test "ensure_authenticated when logged in" do |context|
  context.session["User"] = 1
  assert nil == context.ensure_authenticated(User)
  assert nil == context.redirect
  assert nil == context.session[:return_to]
end

class Admin < Struct.new(:id)
  def self.[](id)
    new(id) unless id.to_s.empty?
  end
end

test "authenticated" do |context|
  context.session["User"] = 1

  assert User.new(1) == context.authenticated(User)
  assert nil == context.authenticated(Admin)
end

test "caches authenticated in @_authenticated" do |context|
  context.session["User"] = 1
  context.authenticated(User)

  assert User.new(1) == context.instance_variable_get(:@_authenticated)[User]
end

test "redirect to stored when :return_to is set" do |context|
  context.session[:return_to] = "/private"
  context.redirect_to_stored

  assert "/private" == context.redirect
  assert nil == context.session[:return_to]
end

test "redirect to stored when no return to" do |context|
  context.redirect_to_stored
  assert "/" == context.redirect

  context.redirect_to_stored("/custom")
  assert "/custom" == context.redirect
end

test "login success" do |context|
  assert context.login(User, "quentin", "password")
  assert 1001 == context.session["User"]
end

test "login failure" do |context|
  assert false == context.login(User, "wrong", "creds")
  assert nil == context.session["User"]
end

test "logout" do |context|
  context.session["User"] = 1001
  context.session[:return_to] = "/foo"

  context.logout(User)

  assert nil == context.session["User"]
  assert nil == context.session[:return_to]
end