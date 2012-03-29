require File.expand_path("helper", File.dirname(__FILE__))
require File.expand_path("user", File.dirname(__FILE__))

Cuba.use Rack::Session::Cookie
Cuba.use Shield::Middleware
Cuba.plugin Shield::Helpers

Cuba.define do
  on get, "public" do
    res.write "Public"
  end

  on get, "private" do
    if authenticated(User)
      res.write "Private"
    else
      res.status = 401
    end
  end

  on get, "login" do
    res.write "Login"
  end

  on post, "login", param("login"), param("password") do |u, p|
    if login(User, u, p, req[:remember_me])
      res.redirect(req[:return] || "/")
    else
      res.redirect "/login"
    end
  end

  on "logout" do
    logout(User)
    res.redirect "/"
  end
end

scope do
  def app
    Cuba
  end

  setup do
    clear_cookies
  end

  test "public" do
    get "/public"
    assert "Public" == last_response.body
  end

  test "successful logging in" do
    get "/private"

    assert_equal "/login?return=%2Fprivate", redirection_url

    post "/login", login: "quentin", password: "password", return: "/private"

    assert_redirected_to "/private"

    assert 1001 == session["User"]
  end

  test "failed login" do
    post "/login", :login => "q", :password => "p"
    assert_redirected_to "/login"

    assert nil == session["User"]
  end

  test "logging out" do
    post "/login", :login => "quentin", :password => "password"

    get "/logout"

    assert nil == session["User"]
  end

  test "remember functionality" do
    post "/login", :login => "quentin", :password => "password", :remember_me => "1"

    assert_equal session[:remember_for], 86400 * 14

    get "/logout"

    assert_equal nil, session[:remember_for]
  end
end
