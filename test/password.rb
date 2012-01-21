require File.expand_path("helper", File.dirname(__FILE__))

# Shield::Password::Simple
scope do
  test "encrypt" do
    encrypted = Shield::Password.encrypt("password")
    assert Shield::Password.check("password", encrypted)
  end

  test "with custom 64 character salt" do
    encrypted = Shield::Password.encrypt("password", "A" * 64)
    assert Shield::Password.check("password", encrypted)
  end

  test "nil password doesn't raise" do
    ex = nil

    begin
      encrypted = Shield::Password.encrypt(nil)
    rescue Exception => e
      ex = e
    end

    assert nil == ex
  end
end

# Shield::Password::PBKDF2
scope do
  setup do
    Shield::Password.strategy = Shield::Password::PBKDF2
  end

  test "encrypt" do
    encrypted = Shield::Password.encrypt("password")
    assert Shield::Password.check("password", encrypted)
  end

  test "with custom 64 character salt" do
    encrypted = Shield::Password.encrypt("password", "A" * 64)
    assert Shield::Password.check("password", encrypted)
  end
end