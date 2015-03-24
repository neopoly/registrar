module Registrar
  module Adapter
    class Params
      def initialize(app, mapping)
        @app = app
        @mapping = mapping
      end

      def call(env)
        builder = Builder.new(env, @mapping)
        builder.build_registrar_params
        builder.overwrite_params

        @app.call(env)
      end

      private

      class Builder
        def initialize(env, mapping)
          @env = env
          @mapping = mapping
        end

        def build_registrar_params
          @mapping.each do |attribute, tupel|
            value = request.params[attribute]
            namespace, attr = tupel.split('#')
            params[namespace][attr] = value
          end
        end

        def overwrite_params
          params.each do |namespace, values|
            request.update_param(namespace, values)
          end
        end

        def request
          @request ||= Rack::Request.new(@env)
        end

        def params
          @params ||= @env['registrar.params'] = Hash.new {|h,k| h[k] = {}}
        end
      end
    end
  end
end
