require File.expand_path("helper", File.dirname(__FILE__))

class User < Shield::User
end

setup do
  User.create(:email => "quentin@email.com", :password => "password",
              :password_confirmation => "password")
end

test "authentication default" do |u|
  assert u == User.authenticate("quentin@email.com", "password")

  assert nil == User.authenticate("quentin@email.com", "pass")
  assert nil == User.authenticate("quentin@email.co.uk", "password")
end

test "email validation" do |u|
  u.email = nil
  assert ! u.valid?
  assert u.errors.include?([:email, :not_present])

  u.email = "foobar"
  assert ! u.valid?
  assert u.errors.include?([:email, :not_email])

  u.email = "foo@bar.com"
  u.save

  foo = User.new(:email => "foo@bar.com")
  assert ! foo.valid?
  assert foo.errors.include?([:email, :not_unique])
end