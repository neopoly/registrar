require 'spec_helper'
require 'omniauth'

class ParamsAdapterSpec < Spec
  it 'normalizes params to registrar schema' do
    get '/'
    assert_normalizes_params env
  end

  private

  def assert_normalizes_params(env)
    assert_normalizes_provider(env)
    assert_normalizes_profile(env)
  end

  def assert_normalizes_provider(env)
    assert_equal(
      {
        'name' => 'facebook',
        'uid' => '100000100277322',
      }, env['registrar.params']['provider'])
  end

  def assert_normalizes_profile(env)
    assert_equal(
      {
        "name" => "Jan Ow",
        "email" => "jan@featurefabrik.de",
      }, env['registrar.params']['profile'])
  end

  def env
    last_request.env
  end

  def response
    last_response
  end

  def app
    @app ||= build_app
  end

  def build_app
    builder.to_app
  end

  class ParamsStub
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      request.update_param('provider', 'facebook')
      request.update_param('external_uid', '100000100277322')
      request.update_param('display_name', 'Jan Ow')
      request.update_param('email', 'jan@featurefabrik.de')
      @app.call(env)
    end
  end

  def builder
    Rack::Builder.new do
      use ParamsStub

      use Registrar::Adapter::Params, {
        "provider#name" => 'provider',
        "provider#uid" => 'external_uid',
        "profile#name" => 'display_name',
        "profile#email" => 'email'
      }

      app = Proc.new do |env|
        ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
      end

      run app
    end
  end
end
