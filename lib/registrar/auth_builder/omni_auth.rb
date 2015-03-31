module Registrar
  module AuthBuilder
    class OmniAuth
      def initialize(app, time = Time)
        @app = app
        @time = time
      end

      def call(env)
        try_to_normalize_auth(env)
        @app.call(env)
      end

      private

      def try_to_normalize_auth(env)
        if env['omniauth.auth']
          env['registrar.auth'] = AuthNormalizer.normalized(env, @time)
        end
      end

      class AuthNormalizer
        def self.normalized(env, time)
          new(env, time).normalize
        end

        def initialize(env, time)
          @env = env
          @time = time
        end

        def normalize
          normalized = {}
          normalized['provider'] = normalize_provider
          normalized['profile'] = normalize_profile
          normalized['trace'] = add_trace
          normalized
        end

        private

        def normalize_provider
          {
            'name' => provider_name,
            'uid' => provider_uid,
            'access_token' => access_token 
          }
        end

        def provider_name
          auth['provider']
        end

        def provider_uid
          auth['uid']
        end

        def access_token
          auth['credentials']['token']
        end

        def normalize_profile
          auth['info'].to_hash
        end

        def add_trace
          {
            'ip' => ip,
            'user_agent' => user_agent,
            'timestamp' => now
          }
        end

        def ip
          request.ip
        end

        def user_agent
          request.user_agent
        end

        def now
          @time.now.to_i.to_s
        end

        def request
          @request ||= Rack::Request.new(env)
        end

        def auth
          @auth ||= env['omniauth.auth']
        end

        def env
          @env
        end
      end
    end
  end
end
