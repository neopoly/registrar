require 'spec_helper'
require 'omniauth'

class OmniAuthAdapterSpec < Spec
  it 'normalizes OmniAuth Auth Hash Schema 1.0 and later' do
    get '/'
    assert_normalizes_auth env
  end

  private

  def assert_normalizes_auth(env)
    assert_normalizes_provider(env)
    assert_normalizes_profile(env)
  end

  def assert_normalizes_provider(env)
    assert_equal(
      {
        'name' => 'facebook',
        'uid' => '100000100277322'
      }, env['registrar.auth']['provider'])
  end

  def assert_normalizes_profile(env)
    assert_equal(
      {
        "name" => "Jan Ow",
        "first_name" => "Jan",
        "last_name" => "Ow",
        "image" => "http://graph.facebook.com/100000100277322/picture",
        "urls" => {
          "Facebook" => "http://www.facebook.com/100000100277322"
        },
        "verified" => true
      }, env['registrar.auth']['profile'])
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

  class OmniAuthFacebookStub
    def initialize(app)
      @app = app
    end

    def call(env)
      env['omniauth.auth'] = stubbed_auth_response
      @app.call(env)
    end

    private

    def stubbed_auth_response
      Marshal.load(auth_response_file)
    end

    def auth_response_file
      File.read(auth_response_path)
    end

    def auth_response_path
      "#{current_path}/fixtures/omniauth_1_0_auth_hash_schema"
    end

    def current_path
      File.expand_path(File.dirname(__FILE__))
    end
  end

  def builder
    Rack::Builder.new do
      use OmniAuthFacebookStub

      use Registrar::Adapter::OmniAuth

      app = Proc.new do |env|
        ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
      end

      run app
    end
  end
end
