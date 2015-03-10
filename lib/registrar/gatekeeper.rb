module Registrar
  class Gatekeeper
    def initialize(app, &block)
      @app = app
      @dispatcher = Dispatcher.new
      try_to_eval_dispatcher(&block)
    end

    def call(env)
      if dispatch?(env)
        dispatch(env).tap do |d|
          env["PATH_INFO"] = d.request_path
          env["REQUEST_METHOD"] = d.request_method
        end
      end

      @app.call(env)
    end

    private

    attr_reader :dispatcher

    def try_to_eval_dispatcher(&block)
      if block_given?
        dispatcher.instance_eval &block
      end
    end

    def dispatch?(env)
      !!dispatch(env)
    end

    def dispatch(env)
      return @dispatch if @dispatch

      request_path = env["PATH_INFO"]
      request_method = env["REQUEST_METHOD"]
      uid = "#{request_path}_#{request_method}"

      @dispatch = dispatcher.dispatches[uid]
    end

    class Dispatcher
      def initialize
        @dispatches = {}
      end

      def get(from, to)
        add_dispatch(from, to, "GET")
      end

      def post(from, to)
        add_dispatch(from, to, "POST")
      end

      def dispatches
        @dispatches
      end

      private

      def add_dispatch(from, to, request_method)
        lookup_key = "#{from}_#{request_method}"
        @dispatches[lookup_key] = build_dispatch(to, request_method)
      end

      def build_dispatch(request_path, request_method)
        Dispatch.new(request_path, request_method)
      end

      class Dispatch
        attr_reader :request_path, :request_method

        def initialize(request_path, request_method)
          @request_path = request_path
          @request_method = request_method
        end
      end
    end
  end
end
