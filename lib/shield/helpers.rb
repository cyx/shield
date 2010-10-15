module Shield
  module Helpers
    def ensure_authenticated
      return if logged_in?

      session[:return_to] = request.fullpath
      redirect "/login"
    end

    def logged_in?
      !! current_user
    end

    def current_user
      @_current_user ||= User[session[:user]]
    end

    def redirect_to_stored(default = "/")
      redirect(session.delete(:return_to) || default)
    end

    def login(username, password)
      user = User.authenticate(username, password)

      if user
        session[:user] = user.id
        return true
      else
        return false
      end
    end

    def logout
      session.delete(:user)
      session.delete(:return_to)
    end
  end
end