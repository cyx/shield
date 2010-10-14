require File.expand_path("helper", File.dirname(__FILE__))

class User < Shield::User
end

class Main < Sinatra::Base
  enable :sessions
  helpers Shield::Helpers

  get "/public" do
    "Public"
  end

  get "/private" do
    ensure_authenticated

    "Private"
  end

  use Shield::Login do |login|
    login.settings.auth_success_message = "Booya!"
    login.settings.auth_failure_message = "BOOM!"
  end
end

scope do
  def app
    Main.new
  end

  setup do
    clear_cookies

    User.create(:email => "quentin@test.com",
                :password => "password",
                :password_confirmation => "password")
  end

  test "public" do
    get "/public"
    assert "Public" == last_response.body
  end

  test "logging in" do
    post "/login", :login => "quentin@test.com", :password => "password"

    get "/private"
    assert "Private" == last_response.body
    assert "Booya!" == session[:success]
  end

  test "login, logout, login failure" do
    post "/login", :login => "quentin@test.com", :password => "password"
    get "/logout"

    post "/login"
    assert "BOOM!" == session[:error]
  end
end