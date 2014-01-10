require "armor"

module Shield
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
    def self.encrypt(password, salt = generate_salt)
      Armor.digest(password, salt) + salt
    end

    def self.check(password, encrypted)
      sha512, salt = encrypted.to_s[0...128], encrypted.to_s[128..-1]

      Armor.compare(Armor.digest(password, salt), sha512)
    end

  protected
    def self.generate_salt
      Armor.hex(OpenSSL::Random.random_bytes(32))
    end
  end
end
