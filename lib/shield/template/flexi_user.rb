module Shield
  class FlexiUser < User
    def self.inherited(model)
      model.attribute :username
      model.index :username

      _copy_attributes_indices_counters(model)
    end

    def self.find_by_login(login)
      super or find(:username => login).first
    end

    def validate
      super

      assert_present(:username) &&
        assert_format(:username, /\A[a-z][a-z0-9\-\_\.]{2,}\z/) &&
        assert_unique(:username)
    end
  end
end