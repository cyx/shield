module Shield
  module Helpers
    def ensure_authenticated(model)
      return if authenticated(model)

      session[:return_to] = request.fullpath
      redirect_to_login
    end

    def authenticated(model)
      @_authenticated ||= {}
      @_authenticated[model] ||= model[session[model.to_s]]
    end

    def redirect_to_login
      redirect "/login"
    end

    def redirect_to_stored(default = "/")
      redirect(session.delete(:return_to) || default)
    end

    def login(model, username, password)
      instance = model.authenticate(username, password)

      if instance
        session[model.to_s] = instance.id
        return true
      else
        return false
      end
    end

    def logout(model)
      session.delete(model.to_s)
      session.delete(:return_to)

      @_authenticated.delete(model) if defined?(@_authenticated)
    end
  end
end