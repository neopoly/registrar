require 'spec_helper'

class GatekeeperSpec < Spec
  it 'delegates get requests to the defined endpoints' do
    get '/login/base'

    assert_path '/auth/developer'
    assert_method 'GET'
  end

  it 'delegates post requests to the defined endpoints' do
    post '/login/base'

    assert_path '/auth/developer/callback'
    assert_method 'POST'
  end

  private

  def assert_path(request_path)
    assert_equal request_path, env["PATH_INFO"]
  end

  def assert_method(request_method)
    assert_equal request_method, env["REQUEST_METHOD"]
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

  def builder
    Rack::Builder.new do
      use Registrar::Gatekeeper do
        get '/login/base', '/auth/developer'
        post '/login/base', '/auth/developer/callback'
      end

      app = Proc.new do |env|
        ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
      end

      run app
    end
  end
end
