module Registrar
  module Adapter
    class Params
      def initialize(app, mapping)
        @app = app
        @mapping = mapping
      end

      def call(env)
        build_registrar_params(env)
        overwrite_params(env)

        @app.call(env)
      end

      private

      def build_registrar_params(env)
        @mapping.each do |tupel, attribute|
          value = request(env).params[attribute]
          namespace, attr = tupel.split('#')
          params(env)[namespace][attr] = value
        end
      end

      def overwrite_params(env)
        params(env).each do |namespace, values|
          request(env).update_param(namespace, values)
        end
      end

      def request(env)
        @request ||= Rack::Request.new(env)
      end

      def params(env)
        @params ||= env['registrar.params'] = Hash.new {|h,k| h[k] = {}}
      end
    end
  end
end
