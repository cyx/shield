Gem::Specification.new do |s|
  s.name = "shield"
  s.version = "0.0.1"
  s.summary = %{Ohm specific authentication solution.}
  s.description = %Q{
    Gets you 80-90% of the way regarding your authentication
    requirements. Provides convenience helper functions which you can
    use with your favorite web framework of choice.
  }
  s.authors = ["Michel Martens", "Damian Janowski", "Cyril David"]
  s.email = ["michel@soveran.com", "djanowski@dimaion.com",
             "cyx@pipetodevnull.com"]
  s.homepage = "http://github.com/cyx/shield"
  s.files = ["lib/shield/helpers.rb", "lib/shield/login.rb", "lib/shield/password.rb", "lib/shield/template/basic_user.rb", "lib/shield/template/flexi_user.rb", "lib/shield/template/user.rb", "lib/shield.rb", "README.markdown", "LICENSE", "Rakefile", "test/basic_user_test.rb", "test/flexi_user_test.rb", "test/helper.rb", "test/login_middleware_test.rb", "test/login_rack_mounting_test.rb", "test/mounted_middleware_test.rb", "test/password_hash_test.rb", "test/shield_test.rb", "test/sinatra_test.rb", "test/user_test.rb"]

  s.rubyforge_project = "shield"
  s.add_development_dependency "cutest"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "haml"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "ohm"
  s.add_development_dependency "ohm-contrib"
  s.add_development_dependency "nokogiri"
end