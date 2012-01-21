require File.expand_path("helper", File.dirname(__FILE__))
require "sinatra/base"

class User < Struct.new(:id)
  extend Shield::Model

  def self.[](id)
    User.new(1) unless id.to_s.empty?
  end

  def self.authenticate(username, password)
    User.new(1001) if username == "quentin" && password == "password"
  end
end

class SinatraApp < Sinatra::Base
  enable :sessions
  helpers Shield::Helpers

  get "/public" do
    "Public"
  end

  get "/private" do
    ensure_authenticated(User)

    "Private"
  end

  get "/login" do
    "Login"
  end

  post "/login" do
    if login(User, params[:login], params[:password], params[:remember_me])
      redirect(session[:return_to] || "/")
    else
      redirect "/login"
    end
  end

  get "/logout" do
    logout(User)
    redirect "/"
  end
end

scope do
  def app
    SinatraApp.new
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

  def debug
    require "open3"
    out, _, _ = Open3.capture3("elinks -dump", stdin_data: last_response.body)
    puts out
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
    assert_equal "/private", session[:return_to]

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