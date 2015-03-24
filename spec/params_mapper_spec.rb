require 'spec_helper'
require 'omniauth'

class ParamsMapperSpec < Spec
  it 'stores normalized params in registrar.params' do
    get '/'
    assert_normalizes_params env['registrar.params']
  end

  it 'normalizes params to registrar schema' do
    get '/'
    assert_normalizes_params Rack::Request.new(env).params
  end

  private

  def assert_normalizes_params(params)
    assert_equal '1', params['uid']
    assert_equal 'facebook', params['provider']['name']
    assert_equal 'jan@featurefabrik.de', params['contact']
    assert_equal '221b Baker Street', params['info']['location']
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
      request.update_param('id', '1')
      request.update_param('provider', 'facebook')
      request.update_param('info', {
        'email' => 'jan@featurefabrik.de',
        'address' => '221b Baker Street'
        }
      )
      @app.call(env)
    end
  end

  def builder
    Rack::Builder.new do
      use ParamsStub

      use Registrar::Mapper::Params, {
        "id" => "uid",
        "provider" => "provider#name",
        "info#email" => "contact",
        "info#address" => "info#location"
      }

      app = Proc.new do |env|
        ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
      end

      run app
    end
  end
end
