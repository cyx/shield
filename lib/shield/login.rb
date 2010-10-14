require "sinatra/base"

module Shield
  class Login < Sinatra::Base
    enable :sessions
    helpers Helpers

    set :views, File.join(File.dirname(__FILE__), "..", "..", "views")

    set :auth_success_message, "You have successfully logged in."
    set :auth_failure_message, "Wrong Username and/or Password combination."

    get "/login/?" do
      haml :login
    end

    post "/login/?" do
      user = ::User.authenticate(params[:login], params[:password])

      if user
        session[:success] = settings.auth_success_message
        session[:user] = user.id

        redirect_to_stored
      else
        session[:error] = settings.auth_failure_message
        redirect "/login"
      end
    end

    get "/logout/?" do
      session.delete(:user)
      session.delete(:return_to)

      redirect "/"
    end
  end
end