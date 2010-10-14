module Shield
  class BasicUser < Ohm::Model
    Unimplemented = Class.new(StandardError)

    def self.inherited(model)
      model.attribute :crypted_password
    end

    # TODO : change this if Ohm decides on implementing subclassing.
    def self._copy_attributes_indices_counters(model)
      attributes.each { |att| model.attribute(att) }
      indices.each    { |att| model.index(att)     }
      counters.each   { |att| model.counter(att)   }
    end

    attr_reader :password, :password_confirmation
    attr_writer :password_confirmation

    def self.authenticate(login, password)
      user = find_by_login(login)

      if user && Shield::Password.check(password, user.crypted_password)
        return user
      end
    end

    def self.find_by_login(login)
      raise Unimplemented
    end

    def password=(password)
      write_local :crypted_password, Shield::Password.encrypt(password)

      @password = password
    end
  end
end