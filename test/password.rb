require "pry"
require_relative "helper"

scope do
  test "armor encryption" do
    encrypted = Shield::Password.encrypt("password")
    assert Shield::Password.check("password", encrypted)
  end

  test "argon2 encryption" do
    encrypted = Shield::Password.encrypt("password", mode: :argon2)
    assert encrypted.include? 'argon2'
    assert Shield::Password.check("password", encrypted)
  end

  test "with custom 64 character salt" do
    encrypted = Shield::Password.encrypt("password", "A" * 64)
    assert Shield::Password.check("password", encrypted)
  end

  test "DOS fix" do
    too_long = '*' * (Shield::Password::MAX_LEN + 1)

    assert_raise Shield::Password::Error do
      Shield::Password.encrypt(too_long)
    end
  end
end
