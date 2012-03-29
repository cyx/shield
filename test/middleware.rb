require File.expand_path("helper", File.dirname(__FILE__))
require File.expand_path("user", File.dirname(__FILE__))

Cuba.use Rack::Session::Cookie
Cuba.use Shield::Middleware

Cuba.plugin Shield::Helpers

Cuba.define do
  on "secured" do
    if not authenticated(User)
      halt [401, { "Content-Type" => "text/html" }, []]
    end

    res.write "You're in"
  end

  on "foo" do
    puts env.inspect
  end
end

test do
  env = { "PATH_INFO" => "/secured", "SCRIPT_NAME" => "" }
  status, headers, body = Cuba.call(env)

  assert_equal 302, status
  assert_equal "/login?return=%2Fsecured", headers["Location"]
end
