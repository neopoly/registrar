require 'spec_helper'
require 'omniauth'

class OmniAuthAuthBuilderSpec < Spec
  it 'normalizes OmniAuth Auth Hash Schema 1.0 and later' do
    get '/'
    assert_normalizes_auth env
  end

  private

  def assert_normalizes_auth(env)
    assert_normalizes_provider(env)
    assert_normalizes_profile(env)
    assert_adds_trace(env)
  end

  def assert_normalizes_provider(env)
    assert_equal(
      {
        'name' => 'facebook',
        'uid' => '100000100277322',
        'access_token' => 'CAACEdEose0cBAJN79Dw0mRoZCGz6ZBBq8VrIkSjh5zQG5fWC156X1uhEUUcjk5bOTXfeeAPDYsFLN48WSpZA73q9D4BmQkD73PYDPYKkjhLH90SPSxctWAZBZB50DNh8TAgxZAJ4JmpEbRtpuex3ovEMGoB9tsQlmDQu1ZAj5Qy2WDSaB88nxLcuaClZAXk2ZCqcuLLjO5kiZAZCyYCET9FCyMlmfzh1HhabapyGSm5DQrDqGN8ZCpm7oUkmfpz3prmShOcZD'
      }, env['registrar.auth']['provider'])
  end

  def assert_normalizes_profile(env)
    assert_equal(
      {
        "name" => "Jan Ow",
        "email" => "janowiesniak@gmx.de",
        "location" => "Bochum, Germany",
        "image" => "http://graph.facebook.com/100000100277322/picture"
      }, env['registrar.auth']['profile'])
  end

  def assert_adds_trace(env)
    assert_equal(
      {
        "ip" => "127.0.0.2",
        "user_agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.91 Safari/537.36",
        "timestamp" => "1427789796"
      }, env['registrar.auth']['trace'])
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

  class TraceStub
    def initialize(app)
      @app = app
    end

    def call(env)
      env['HTTP_USER_AGENT'] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.91 Safari/537.36"
      env['REMOTE_ADDR'] = "127.0.0.2"
      @app.call(env)
    end
  end

  class TimeStub
    def now
      Time.at(1427789796)
    end
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
      use TraceStub
      use OmniAuthFacebookStub

      use Registrar::AuthBuilder::OmniAuth, TimeStub.new

      app = Proc.new do |env|
        ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
      end

      run app
    end
  end
end
