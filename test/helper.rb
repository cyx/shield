$:.unshift(File.expand_path("../lib", File.dirname(__FILE__)))

require "shield"
require "cutest"
require "rack/test"
require "sinatra/base"

class Cutest::Scope
  include Rack::Test::Methods

  def assert_redirected_to(path)
    assert_equal 302,  last_response.status
    assert_equal path, URI(last_response.headers["Location"]).path
  end

  def session
    last_request.env["rack.session"]
  end
end