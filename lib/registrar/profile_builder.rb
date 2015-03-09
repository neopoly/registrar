module Registrar
  class ProfileBuilder
    def initialize(app, callable)
      @app = app
      @callable = callable
    end

    def call(env)
      try_to_call(env)
      @app.call(env)
    end

    private

    def try_to_call(env)
      if auth_hash = env['registrar.auth']
        profile = @callable.call(auth_hash)
        env['registrar.profile'] = profile.to_hash
      end
    end
  end
end
