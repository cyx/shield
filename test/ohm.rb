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
  Ohm.flush
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
