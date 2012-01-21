require File.expand_path("helper", File.dirname(__FILE__))

class User < Struct.new(:id)
  extend Shield::Model

  def self.[](id)
    User.new(1) unless id.to_s.empty?
  end

  def self.authenticate(username, password)
    User.new(1001) if username == "quentin" && password == "password"
  end
end

Cuba.use Rack::Session::Cookie

Cuba.send :include, Shield::Helpers

Cuba.define do
  on get, "public" do
    res.write "Public"
  end

  on get, "private" do
    ensure_authenticated(User)

    res.write "Private"
  end

  on get, "login" do
    res.write "Login"
  end

  on post, "login", param("login"), param("password") do |u, p|
    if login(User, u, p, req[:remember_me])
      res.redirect(session[:return_to] || "/")
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

  def assert_redirected_to(path)
    unless last_response.status == 302
      flunk
    end
    assert_equal path, URI(last_response.headers["Location"]).path
  end

  def session
    last_request.env["rack.session"]
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

    assert_redirected_to "/login"
    assert "/private" == session[:return_to]

    post "/login", :login => "quentin", :password => "password"
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
    assert nil == session[:return_to]
  end

  test "remember functionality" do
    post "/login", :login => "quentin", :password => "password", :remember_me => "1"

    assert_equal session[:remember_for], 86400 * 14

    get "/logout"

    assert_equal nil, session[:remember_for]
  end
end
