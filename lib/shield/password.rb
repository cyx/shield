require "digest/sha2"

module Shield
  module Password
    autoload :Simple, "shield/password/simple"
    autoload :PBKDF2, "shield/password/pbkdf2"

    def self.strategy=(s)
      @strategy = s
    end

    def self.strategy
      @strategy ||= Shield::Password::Simple
    end

    def self.encrypt(password, salt = generate_salt)
      strategy.encrypt(password, salt)
    end

    def self.check(password, encrypted)
      strategy.check(password, encrypted)
    end

    def self.generate_salt
      Digest::SHA512.hexdigest(Time.now.to_f.to_s)[0, 64]
    end
  end
end