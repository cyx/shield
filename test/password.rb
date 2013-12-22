require File.expand_path("helper", File.dirname(__FILE__))

scope do
  test "encrypt" do
    encrypted = Shield::Password.encrypt("password")
    assert Shield::Password.check("password", encrypted)
  end

  test "with custom 64 character salt" do
    encrypted = Shield::Password.encrypt("password", "A" * 64)
    assert Shield::Password.check("password", encrypted)
  end
end
