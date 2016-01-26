require "armor"
require "argon2"
require "uri"

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

  module Model
    def self.included(model)
      model.extend(ClassMethods)
    end

    class FetchMissing < StandardError; end

    module ClassMethods
      def authenticate(username, password)
        user = fetch(username)

        if user and is_valid_password?(user, password)
          return user
        end
      end

      def fetch(login)
        raise FetchMissing, "#{self}.fetch not implemented"
      end

      def is_valid_password?(user, password)
        Shield::Password.check(password, user.crypted_password)
      end
    end

    def password=(password, mode: :argon2)
      self.crypted_password = Shield::Password.encrypt(password.to_s, mode)
    end
  end

  module Password
    attr_reader :encryption_mode

    Error = Class.new(StandardError)

    # == DOS attack fix
    #
    # Excessively long passwords (e.g. 1MB strings) would hang
    # a server.
    #
    # @see: https://www.djangoproject.com/weblog/2013/sep/15/security/
    MAX_LEN = 4096

    def self.encrypt(password, salt = generate_salt, mode: :armor)
      @encryption_mode = mode

      case @encryption_mode
      when :armor   then digest_with_armor(password, salt) + salt
      when :argon2  then digest_with_argon2(password)
      end
    end

    def self.check(password, encrypted)
      case @encryption_mode
      when :armor
        sha512, salt = encrypted.to_s[0...128], encrypted.to_s[128..-1]
        Armor.compare(digest_with_armor(password, salt), sha512)
      when :argon2
        Argon2::Password.verify_password(password, encrypted)
      else
        raise Error, ":armor and :argon2 are the only supported encryption methods at this time."
      end
    end

  protected
    def self.digest_with_armor(password, salt)
      raise Error if password.length > MAX_LEN

      Armor.digest(password, salt)
    end

    def self.generate_salt
      Armor.hex(OpenSSL::Random.random_bytes(32))
    end

    def self.digest_with_argon2(password)
      Argon2::Password.hash(password)
    end
  end
end
