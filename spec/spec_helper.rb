require 'minitest/autorun'
require 'rack'
require 'rack/test'
require 'registrar'

class Spec < Minitest::Spec
  include Rack::Test::Methods
end
