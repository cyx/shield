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
end

$app = Rack::Builder.app {
  use Shield::Login

  map "/" do
    run Main
  end
}

scope do
  def app
    $app
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
    post "/login", :login => "quentin@test.com",
                   :password => "password"

    get "/private"
    assert "Private" == last_response.body
  end

  test "being redirected and then logging in" do
    get "/private"
    assert_redirected_to "/login"

    post "/login", :login => "quentin@test.com", :password => "password"
    assert_redirected_to "/private"
  end
end