module Shield
  module Helpers
    class NoSession < StandardError
      def message
        "You must enable sessions to use Shield."
      end
    end

    def session
      env["rack.session"] || raise(NoSession)
    end

    def redirect(path, status = 302)
      halt [status, { "Location" => path, "Content-Type" => "text/html" }, []]
    end

    def ensure_authenticated(model, login_url = "/login")
      if authenticated(model)
        return true
      else
        session[:return_to] = req.fullpath
        redirect login_url
        return false
      end
    end

    def authenticated(model)
      @_authenticated ||= {}
      @_authenticated[model] ||= session[model.to_s] && model[session[model.to_s]]
    end

    def persist_session!
      if session[:remember_for]
        env["rack.session.options"][:expire_after] = session[:remember_for]
      end
    end

    def login(model, username, password, remember = false, expire = 1209600)
      instance = model.authenticate(username, password)

      if instance
        session[:remember_for] = expire if remember
        session[model.to_s] = instance.id
      else
        return false
      end
    end

    def logout(model)
      session.delete(model.to_s)
      session.delete(:return_to)
      session.delete(:remember_for)

      @_authenticated.delete(model) if defined?(@_authenticated)
    end

    def authenticate(user)
      session[user.class.to_s] = user.id
    end
  end
end