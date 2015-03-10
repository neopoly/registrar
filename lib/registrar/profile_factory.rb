module Registrar
  class ProfileFactory
    def initialize(app, callable)
      @app = app
      @callable = callable
    end

    def call(env)
      build_profile(env)
      @app.call(env)
    end

    private

    def build_profile(env)
      if auth_hash = env['registrar.auth']
        profile = @callable.call(auth_hash)
        env['registrar.profile'] = profile.to_hash
      end
    end
  end
end
