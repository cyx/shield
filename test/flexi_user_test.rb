require File.expand_path("helper", File.dirname(__FILE__))

class FlexiUser < Shield::FlexiUser
end

setup do
  FlexiUser.create(:email => "quentin@test.com",
                   :username => "quentin",
                   :password => "password",
                   :password_confirmation => "password")
end

test "find_by_login" do |u|
  assert u == FlexiUser.find_by_login("quentin@test.com")
  assert u == FlexiUser.find_by_login("quentin")
end

test "authenticate" do |u|
  assert u == FlexiUser.authenticate("quentin", "password")
  assert u == FlexiUser.authenticate("quentin@test.com", "password")
end

test "username validation" do |u|
  u.username = nil
  assert ! u.valid?
  assert u.errors.include?([:username, :not_present])

  ["1foo", "fo", "foo^", "foo&", "foo#"].each do |username|
    u.username = username
    assert ! u.valid?
    assert u.errors.include?([:username, :format])
  end

  u.username = "foo"
  assert u.valid?

  newuser = FlexiUser.new(:username => "quentin")
  assert ! newuser.valid?
  assert newuser.errors.include?([:username, :not_unique])
end