module Registrar
  module Adapter
    class OmniAuth
      def initialize(app)
        @app = app
      end

      def call(env)
        try_to_normalize_auth(env)
        @app.call(env)
      end

      private

      def try_to_normalize_auth(env)
        if env["omniauth.auth"]
          env['registrar.auth'] = AuthNormalizer.normalized(env)
        end
      end

      class AuthNormalizer
        def self.normalized(env)
          normalizer = new(env)
          normalizer.send(:normalize)
          normalizer.send(:normalized)
        end

        private

        attr_reader :auth, :normalized

        def initialize(env)
          @auth = env["omniauth.auth"]
          @normalized = {}
        end

        def normalize
          normalize_provider
          normalize_profile
        end

        def normalize_provider
          provider_name = auth["provider"]
          provider_uid = auth["uid"]

          normalized.merge!(
            'provider' => {
              'name' => provider_name,
              'uid' => provider_uid
            }
          )
        end

        def normalize_profile
          normalized.merge!(
            'profile' => {}
          )

          auth["info"].to_hash.each_pair do |k, v|
            normalized['profile'][k] = v
          end
        end
      end
    end
  end
end
