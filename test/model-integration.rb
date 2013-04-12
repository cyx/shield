require_relative "helper"

class User
  include Shield::Model

  attr_accessor :email, :crypted_password

  def self.fetch(email)
    $users[email]
  end

  def initialize(email, password)
    @email = email
    self.password = password
  end
end

setup do
  $users = {}
  $users["foo@bar.com"] = User.new("foo@bar.com", "pass1234")
end

test "fetch" do |user|
  assert_equal user, User.fetch("foo@bar.com")
end

test "authenticate" do |user|
  assert_equal user, User.authenticate("foo@bar.com", "pass1234")
end
