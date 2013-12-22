require File.expand_path("helper", File.dirname(__FILE__))

class User < Struct.new(:crypted_password)
  include Shield::Model
end

test "fetch" do
  ex = nil

  begin
    User.fetch("quentin")
  rescue Exception => ex
  end

  assert ex.kind_of?(Shield::Model::FetchMissing)
  assert "User.fetch not implemented" == ex.message
end

test "is_valid_password?" do
  user = User.new(Shield::Password.encrypt("password"))

  assert User.is_valid_password?(user, "password")
  assert ! User.is_valid_password?(user, "password1")
end

class User
  class << self
    attr_accessor :fetched
  end

  def self.fetch(username)
    return fetched if username == "quentin"
  end
end

test "authenticate" do
  user = User.new(Shield::Password.encrypt("pass"))

  User.fetched = user

  assert user == User.authenticate("quentin", "pass")
  assert nil == User.authenticate("unknown", "pass")
  assert nil == User.authenticate("quentin", "wrongpass")
end

test "#password=" do
  u = User.new
  u.password = "pass1234"

  assert Shield::Password.check("pass1234", u.crypted_password)
end
