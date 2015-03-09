module Registrar
  class Debug
    def initialize(app)
      @app = app
    end

    def call(env)
      add_debug_info(env)
      @app.call(env)
    end

    private

    def add_debug_info(env)
      debug = {
        'registrar.auth' => env['registrar.auth'],
        'registrar.profile' => env['registrar.profile']
      }

      env['registrar.debug'] = to_html(debug)
    end

    def to_html(debug)
      "
        <!DOCTYPE html>
        <html>
          <head>
            <title>My App</title>
          </head>

          <body>
            <pre style='white-space:pre-wrap;'>#{debug}</pre>
          </body>
        </html>
      ".gsub(/\s{2,}/,' ')
    end
  end
end
