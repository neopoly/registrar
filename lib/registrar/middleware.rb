require 'omniauth'

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
      if config.middleware.respond_to?(:insert_before)
        config.middleware.insert_before ActionDispatch::Cookies,
          Registrar::Mapper::Params, config.attributes
      else
        config.middleware.use Registrar::Mapper::Params, config.attributes
      end
    end

    def self.convert_registrar_schema_to_omniauth_schema
      if config.middleware.respond_to?(:insert_before)
        config.middleware.insert_before ActionDispatch::Cookies, Registrar::Mapper::OmniAuth
      else
        config.middleware.use Registrar::Mapper::OmniAuth
      end
    end

    def self.add_omniauth_strategies
      strategies = config.strategies

      if strategies.respond_to?(:each)
        strategies.each do |strategy|
          add_omniauth_strategy(strategy)
        end
      else
        add_omniauth_strategy(strategies)
      end
    end

    def self.add_omniauth_strategy(strategy)
      filename = "omniauth-#{strategy.gsub('_','-')}"
      provider_name = strategy.gsub('-','_')

      require filename

      if config.middleware.respond_to?(:insert_before)
        config.middleware.insert_before ActionDispatch::Cookies, ::OmniAuth::Builder do
          provider provider_name
        end
      else
        config.middleware.use ::OmniAuth::Builder do
          provider provider_name
        end
      end
    end

    def self.convert_omniauth_schema_to_registrar_schema
      if config.middleware.respond_to?(:insert_before)
        config.middleware.insert_before ActionDispatch::Cookies, Registrar::AuthBuilder::OmniAuth
      else
        config.middleware.use Registrar::AuthBuilder::OmniAuth
      end
    end

    def self.add_registrar_handler
      if config.middleware.respond_to?(:insert_before)
        config.middleware.insert_before ActionDispatch::Cookies, Registrar::ProfileBuilder, config.handler
      else
        config.middleware.use Registrar::ProfileBuilder, config.handler
      end
    end

    def self.config
      @config ||= Registrar::Middleware::Config.new
    end

    class Config
      def strategies(*args)
        @strategies ||= args
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
