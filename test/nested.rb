require_relative "helper"
require_relative "user"
require "cuba"

Cuba.use Rack::Session::Cookie, secret: "R6zSBQWz0VGVSwvT8THurhJwaVqzpnsH27J5FoI58pxoIciDQYvE4opVvDTLMyfjj7c5inIc6PDNaQWvArMvK3"
Cuba.plugin Shield::Helpers

class Admin < Cuba
  use Shield::Middleware, "/login"

  define do
    on "login" do
      res.write "Login"
    end

    on default do
      res.status = 401
    end
  end
end

Cuba.define do
  on "admin" do
    run Admin
  end
end

scope do
  def app
    Cuba
  end

  setup do
    clear_cookies
  end

  test "return + return flow" do
    get "/admin"
    assert_equal "/admin/login?return=%2Fadmin", redirection_url
  end
end
