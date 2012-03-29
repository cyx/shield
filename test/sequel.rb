require_relative "helper"
require "sequel"

DB = Sequel.sqlite

DB.run(%(
  CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    crypted_password VARCHAR(255)
  )
))

class User < Sequel::Model
  include Shield::Model

  def self.fetch(email)
    filter(email: email).first
  end
end

prepare do
  User.truncate
end

setup do
  User.create(email: "foo@bar.com", password: "pass1234")
end

test "fetch" do |user|
  assert_equal user, User.fetch("foo@bar.com")
end

test "authenticate" do |user|
  assert_equal user, User.authenticate("foo@bar.com", "pass1234")
end
