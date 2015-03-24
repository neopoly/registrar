module Registrar
  module Adapter
    class Params
      def initialize(app, mapping)
        @app = app
        @mapping = mapping
      end

      def call(env)
        @mapping.each do |tupel, attribute|
          value = request(env).params[attribute]
          namespace, attr = tupel.split('#')
          params(env)[namespace][attr] = value
        end

        @app.call(env)
      end

      private

      def request(env)
        @request ||= Rack::Request.new(env)
      end

      def params(env)
        @params ||= env['registrar.params'] = Hash.new {|h,k| h[k] = {}}
      end
    end
  end
end
