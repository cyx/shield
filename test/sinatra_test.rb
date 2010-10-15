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
    if login(User, params[:login], params[:password])
      redirect_to_stored
    else
      redirect_to_login
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
end