require File.expand_path("helper", File.dirname(__FILE__))

class BasicUser < Shield::BasicUser
end

setup do
  BasicUser.create(:password => "password")
end

test "allows password checks at the minimum" do |u|
  assert Shield::Password.check("password", u.crypted_password)
end

test "no find_by_login" do
  assert_raise Shield::BasicUser::Unimplemented do
    BasicUser.authenticate("quentin", "password")
  end

  assert_raise Shield::BasicUser::Unimplemented do
    BasicUser.find_by_login("quentin")
  end
end

test "has password confirmation accesors" do |u|
  u.password_confirmation = "pass"

  assert "pass" == u.password_confirmation
end

test "writes the new crypted password on set" do
  u = BasicUser.new(:password => "mypass")
  assert Shield::Password.check("mypass", u.crypted_password)

  u.save
  u = BasicUser[u.id]
  assert Shield::Password.check("mypass", u.crypted_password)
end