require "uri"
require_relative "shield/model"

module Shield
  class Middleware
    attr :url

    def initialize(app, url = "/login")
      @app = app
      @url = url
    end

    def call(env)
      tuple = @app.call(env)

      if tuple[0] == 401
        [302, headers(env["SCRIPT_NAME"] + env["PATH_INFO"]), []]
      else
        tuple
      end
    end

  private
    def headers(path)
      { "Location" => "%s?return=%s" % [url, encode(path)],
        "Content-Type" => "text/html",
        "Content-Length" => "0"
      }
    end

    def encode(str)
      URI.encode_www_form_component(str)
    end
  end

  module Helpers
    def persist_session!
      if session[:remember_for]
        env["rack.session.options"][:expire_after] = session[:remember_for]
      end
    end

    def authenticated(model)
      @_shield ||= {}
      @_shield[model] ||= session[model.to_s] && model[session[model.to_s]]
    end

    def authenticate(user)
      session.clear
      session[user.class.to_s] = user.id
    end

    def login(model, username, password)
      user = model.authenticate(username, password)
      authenticate(user) if user
    end

    def remember(expire = 1209600)
      session[:remember_for] = expire
    end

    def logout(model)
      session.delete(model.to_s)
      session.delete(:remember_for)

      @_shield.delete(model) if defined?(@_shield)
    end
  end
end
