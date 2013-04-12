require "openssl"
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
      session[user.class.to_s] = user.id
    end

    def login(model, username, password, remember = false, expire = 1209600)
      return unless user = model.authenticate(username, password)

      session[:remember_for] = expire if remember
      authenticate(user)
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

    def password=(password)
      self.crypted_password = Shield::Password.encrypt(password.to_s)
    end
  end

  module Password
    class << self
      attr_accessor :iterations, :hash_function
    end

    @iterations = 5000
    @hash_function = OpenSSL::Digest::SHA512.new

    def self.encrypt(password, salt = generate_salt)
      digest(password, salt) + salt
    end

    def self.check(password, encrypted)
      sha512, salt = encrypted.to_s[0...hash_length], encrypted.to_s[hash_length..-1]

      compare(digest(password, salt), sha512)
    end

  protected
    def self.hash_length
      hash_function.length * 2
    end

    def self.generate_salt
      hex_string OpenSSL::Random.random_bytes(32)
    end

    def self.digest(password, salt)
      hex_string(pbkdf2_hmac(password, salt))
    end

    def self.pbkdf2_hmac(password, salt)
      OpenSSL::PKCS5.pbkdf2_hmac(password, salt,
                                 iterations,
                                 hash_function.digest_length,
                                 hash_function)
    end

    def self.hex_string(binary_string)
      binary_string.unpack("H*").first
    end

    # Time-attack safe comparison operator.
    #
    # @see http://bit.ly/WHHHz1
    def self.compare(a, b)
      return false unless a.length == b.length

      cmp = b.bytes.to_a
      result = 0

      a.bytes.each_with_index do |char,index|
        result |= char ^ cmp[index]
      end

      return result == 0
    end
  end
end
