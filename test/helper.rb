require File.expand_path("../lib/shield", File.dirname(__FILE__))

require "cutest"
require "sinatra/base"
require "rack/test"

class Cutest::Scope
  include Rack::Test::Methods

  def assert_redirected_to(path)
    assert 302  == last_response.status
    assert path == last_response.headers["Location"]
  end

  def session
    last_request.env["rack.session"]
  end
end
