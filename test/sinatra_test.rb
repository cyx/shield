require File.expand_path("helper", File.dirname(__FILE__))

class User < Shield::User
end

class SinatraApp < Sinatra::Base
  enable :sessions

  helpers Shield::Helpers

  get "/public" do
    "Public"
  end

  get "/private" do
    ensure_authenticated

    "Private"
  end

  post "/login" do
    user = User.authenticate(params[:login], params[:password])

    if user
      session[:success] = "Success"
      redirect_to_stored
    else
      session[:error] = "Failure"
      redirect "/login"
    end
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
end