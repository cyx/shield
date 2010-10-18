module Shield
  module Model
    def authenticate(username, password)
      user = fetch(username)

      if user and is_valid_password?(user, password)
        return user
      end
    end

    def fetch(login)
      raise FetchMissing
    end

    def is_valid_password?(user, password)
      Shield::Password.check(password, user.crypted_password)
    end

    class FetchMissing < Class.new(StandardError)
      def message
        %{
          !! You need to implement `fetch`.
          Below is a quick example implementation (in Ohm):

            def fetch(email)
              find(:email => email).first
            end

          For more example implementations, check out
          http://github.com/cyx/shield-contrib
        }.gsub(/^ {10}/, "")
      end
    end
  end
end