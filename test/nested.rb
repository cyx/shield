require File.expand_path("helper", File.dirname(__FILE__))
require File.expand_path("user", File.dirname(__FILE__))

Cuba.use Rack::Session::Cookie
Cuba.plugin Shield::Helpers

class Admin < Cuba
  use Shield::Middleware, "/admin/login"

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
