$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "shield"
require "cutest"
require "rack/test"
require "cuba"

class Cutest::Scope
  include Rack::Test::Methods
end