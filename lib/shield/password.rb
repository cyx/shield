require "digest/sha2"

module Shield
  module Password
    def self.encrypt(password, salt = generate_salt)
      digest(password, salt) + salt
    end

    def self.check(password, encrypted)
      sha512, salt = encrypted.to_s[0..127], encrypted.to_s[128..-1]

      digest(password, salt) == sha512
    end

  private
    def self.digest(password, salt)
      Digest::SHA512.hexdigest("#{ password }#{ salt }")
    end

    def self.generate_salt
      Digest::SHA512.hexdigest(Time.now.to_f.to_s)[0, 64]
    end
  end
end