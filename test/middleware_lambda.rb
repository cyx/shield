require_relative "helper"
require_relative "user"
require "cuba"

Cuba.use Rack::Session::Cookie, secret: "foo"
Cuba.use Shield::Middleware, lambda { |env| env["SCRIPT_NAME"] + "/login" } 

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
  env = { "PATH_INFO" => "/secured", "SCRIPT_NAME" => "/lambda" }
  status, headers, body = Cuba.call(env)

  assert_equal 302, status
  assert_equal "/lambda/login?return=%2Flambda%2Fsecured", headers["Location"]
end
