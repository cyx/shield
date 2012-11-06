require_relative "helper"
require "ohm"

class User < Ohm::Model
  include Shield::Model

  attribute :email
  attribute :crypted_password
  index :email

  def self.fetch(email)
    find(email: email).first
  end
end

prepare do
  Ohm.connect :db => ENV.fetch("SHIELD_TEST_REDIS_DB", 15)
  unless Ohm.redis.keys.empty?
    raise "Redis db has data! Aborting tests to prevent flushdb!"
  end
  Ohm.flush
end

setup do
  User.create(email: "foo@bar.com", password: "pass1234")
end

test "fetch" do |user|
  assert_equal user, User.fetch("foo@bar.com")
  Ohm.flush
end

test "authenticate" do |user|
  assert_equal user, User.authenticate("foo@bar.com", "pass1234")
  Ohm.flush
end
