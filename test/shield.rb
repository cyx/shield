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

  def env
    { "SCRIPT_NAME" => "", "PATH_INFO" => @path }
  end

  def session
    @session ||= {}
  end

  class Request < Struct.new(:fullpath)
  end

  def req
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

test "caches authenticated in @_shield" do |context|
  context.session["User"] = 1
  context.authenticated(User)

  assert User.new(1) == context.instance_variable_get(:@_shield)[User]
end

test "login success" do |context|
  assert context.login(User, "quentin", "password")
  assert 1001 == context.session["User"]
end

test "login failure" do |context|
  assert ! context.login(User, "wrong", "creds")
  assert nil == context.session["User"]
end

test "logout" do |context|
  context.session["User"] = 1001

  # Now let's make it memoize the User
  context.authenticated(User)

  context.logout(User)

  assert nil == context.session["User"]
  assert nil == context.authenticated(User)
end

test "authenticate" do |context|
  context.authenticate(User[1001])

  assert User[1] == context.authenticated(User)
end
