require "cutest"
require "rack/test"
require "cuba"

require File.expand_path("../lib/shield", File.dirname(__FILE__))

class Cutest::Scope
  include Rack::Test::Methods

  def assert_redirected_to(path)
    unless last_response.status == 302
      flunk
    end
    assert_equal path, URI(last_response.headers["Location"]).path
  end

  def redirection_url
    last_response.headers["Location"]
  end

  def session
    last_request.env["rack.session"]
  end
end
