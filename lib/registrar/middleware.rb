require 'omniauth'
require 'omniauth-registrar'

module Registrar
  module Middleware
    def self.configure(&blk)
      yield config

      convert_params_to_registrar_schema
      convert_registrar_schema_to_omniauth_schema
      add_omniauth_strategies
      convert_omniauth_schema_to_registrar_schema
      add_registrar_handler
    end

    private

    def self.convert_params_to_registrar_schema
      config.middleware.use Registrar::Mapper::Params, config.attributes
    end

    def self.convert_registrar_schema_to_omniauth_schema
      config.middleware.use Registrar::Mapper::OmniAuth
    end

    def self.add_omniauth_strategies
      name = config.name
      config.middleware.use ::OmniAuth::Builder do
        provider name
      end
    end

    def self.convert_omniauth_schema_to_registrar_schema
      config.middleware.use Registrar::AuthBuilder::OmniAuth
    end

    def self.add_registrar_handler
      config.middleware.use Registrar::ProfileBuilder, config.handler
    end

    def self.config
      @config ||= Registrar::Middleware::Config.new
    end

    class Config
      def name(arg = nil)
        @name ||= arg
      end

      def attributes(arg = nil)
        @attributes ||= arg
      end

      def handler(arg = nil)
        @handler ||= arg
      end

      def middleware(arg = nil)
        @middleware ||= arg
      end
    end

  end
end
