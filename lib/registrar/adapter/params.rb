module Registrar
  module Adapter
    class Params
      def initialize(app, mapping)
        @app = app
        @mapping = mapping
      end

      def call(env)
        request = Rack::Request.new(env)
        @mapping.each do |key, value|
          request.update_param(value.to_s, request.params[key])
        end
        @app.call(env)
      end
    end
  end
end
