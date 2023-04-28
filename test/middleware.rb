require_relative "helper"
require_relative "user"
require "cuba"

Cuba.use Rack::Session::Cookie, secret: "R6zSBQWz0VGVSwvT8THurhJwaVqzpnsH27J5FoI58pxoIciDQYvE4opVvDTLMyfjj7c5inIc6PDNaQWvArMvK3"
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

test do
  env = { "PATH_INFO" => "/secured", "SCRIPT_NAME" => "/suburi" }
  status, headers, body = Cuba.call(env)

  assert_equal 302, status
  assert_equal "/suburi/login?return=%2Fsuburi%2Fsecured", headers["Location"]
end
