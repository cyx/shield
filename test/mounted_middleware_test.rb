require File.expand_path("helper", File.dirname(__FILE__))

class User < Shield::User
end

class App < Sinatra::Base
  enable :sessions

  helpers Shield::Helpers
end

class Main < App
  get "/public" do
    "Public"
  end

  get "/private" do
    ensure_authenticated

    "Private"
  end
end

class Admin < App
  before do
    ensure_authenticated unless request.fullpath == "/admin/login"
  end

  get "/events" do
    "Events"
  end

  get "/sponsors" do
    "Sponsors"
  end

  post "/login" do
    user = User.authenticate(params[:login], params[:password])

    if user
      session[:success] = "Success"
      session[:user] = user.id

      redirect_to_stored
    else
      session[:error] = "Failure"
      redirect "/login"
    end
  end
end

$app = Rack::Builder.app {
  map "/" do
    run Main
  end

  map "/admin" do
    run Admin
  end
}

scope do
  def app
    $app
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

  test "all admin routes" do
    get "/admin/events"
    assert_redirected_to "/login"
    assert "/admin/events" == session[:return_to]

    get "/admin/sponsors"
    assert_redirected_to "/login"
    assert "/admin/sponsors" == session[:return_to]
  end

  test "single sign on" do
    post "/admin/login", :login => "quentin@test.com",
                         :password => "password"

    get "/private"
    assert "Private" == last_response.body
  end
end