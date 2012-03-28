require File.expand_path("helper", File.dirname(__FILE__))

class User < Struct.new(:crypted_password)
  extend Shield::Model
end

test "fetch" do
  ex = nil

  begin
    User.fetch("quentin")
  rescue Exception => e
    ex = e
  end

  assert ex.kind_of?(Shield::Model::FetchMissing)
  assert Shield::Model::FetchMissing.new.message == ex.message
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
