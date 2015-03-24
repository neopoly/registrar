require 'spec_helper'
require 'omniauth'

class ParamsAdapterSpec < Spec
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
    assert_equal(
      {
        'uid' => '1',
        'provider' => {
          'name' => 'facebook'
        },
        'contact' => 'jan@featurefabrik.de',
        'info' => {
          'location' => '221b Baker Street'
        }
      }, params
    )
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

      use Registrar::Adapter::Params, {
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
