require "pbkdf2"

module Shield
  module Password
    module PBKDF2
      extend Shield::Password::Simple

      def self.digest(password, salt)
        ::PBKDF2.new do |p|
          p.password = password
          p.salt = salt
          p.iterations = iterations
          p.hash_function = :sha512
        end.hex_string
      end

      class << self
        attr_accessor :iterations
      end
      @iterations = 5000
    end
  end
end