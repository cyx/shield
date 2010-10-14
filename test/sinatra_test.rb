require File.expand_path("helper", File.dirname(__FILE__))

class User < Shield::User
end

class SinatraApp < Sinatra::Base
  enable :sessions
  register Shield

  get "/public" do
    "Public"
  end

  get "/private" do
    ensure_authenticated

    "Private"
  end
end

scope do
  def app
    SinatraApp.new
  end

  setup do
    User.create(:email => "quentin@test.com",
                :password => "password",
                :password_confirmation => "password")
  end

  test "public" do
    get "/public"
    assert "Public" == last_response.body
  end

  test "private" do
    get "/private"
    assert_redirected_to "/login"
    assert "/private" == session[:return_to]

    post "/login", :login => "quentin@test.com", :password => "password"
    assert_redirected_to "/private"
  end

  test "GET /login response" do
    get "/login"

    doc = Nokogiri(%{<div>#{last_response.body}</div>})

    assert 2 == doc.search("form > fieldset > label > input").size
    assert 1 == doc.search("form > fieldset > button").size
  end
end

class LoginCustomized < Sinatra::Base
  enable :sessions
  set :views, File.join(File.dirname(__FILE__), "fixtures", "views")

  register Shield
end

scope do
  def app
    LoginCustomized.new
  end

  test "login response" do
    get "/login"

    assert "<h1>Login</h1>" == last_response.body.strip
  end
end