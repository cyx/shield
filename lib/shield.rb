module Shield
  VERSION = "0.0.0"

  autoload :BasicUser, "shield/template/basic_user"
  autoload :User,      "shield/template/user"
  autoload :FlexiUser, "shield/template/flexi_user"
  autoload :Password,  "shield/password"
  autoload :Login,     "shield/login"
  autoload :Helpers,   "shield/helpers"

  def self.registered(app)
    app.helpers Helpers

    app.use Login do |m|
      m.settings.set :views, app.views if app.views
    end
  end
end
