require "ohm/contrib"

module Shield
  class User < BasicUser
    include Ohm::WebValidations

    def self.inherited(model)
      model.attribute :email
      model.index :email

      _copy_attributes_indices_counters(model)
    end

    def self.find_by_login(login)
      find(:email => login).first
    end

    def validate
      super

      assert_present(:email) && assert_email(:email) && assert_unique(:email)

      if new?
        assert_present :password
      end

      unless password.to_s.empty?
        assert password == password_confirmation, [:password, :not_confirmed]
      end
    end
  end
end