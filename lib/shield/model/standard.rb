class User < Ohm::Model
  include Shield::Model::Ohm
end

module Shield
  module Model
    module Standard
      def password=(password)
        if password.nil?
          self.crypted_password = nil
        else
          self.crypted_password = Shield::Password.encrypt(password)
        end
      end
    end
  end
end
