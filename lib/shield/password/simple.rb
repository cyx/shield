module Shield
  module Password
    module Simple
      extend self

      def encrypt(password, salt)
        digest(password, salt) + salt
      end

      def check(password, encrypted)
        sha512, salt = encrypted.to_s[0..127], encrypted.to_s[128..-1]

        digest(password, salt) == sha512
      end

    private
      def digest(password, salt)
        Digest::SHA512.hexdigest("#{ password }#{ salt }")
      end
    end
  end
end