require File.expand_path("../../lib/impersonation/app.rb", __FILE__)
require 'rack/test'
require 'webmock'

WebMock.disable_net_connect!

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  @test_org_repo = "Octocats/test_impersonation"
end
