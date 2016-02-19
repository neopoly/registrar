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
          env['registrar.auth'] = Builder.build(env, @time)
        end
      end

      class Builder
        def self.build(env, time)
          new(env, time).build
        end

        def initialize(env, time)
          @env = env
          @time = time
        end

        def build
          Hash.new.tap do |schema|
            schema['provider'] = provider
            schema['profile'] = profile
            schema['trace'] = trace
          end
        end

        private

        def provider
          {
            'name' => provider_name,
            'uid' => provider_uid,
            'access_token' => provider_access_token
          }
        end

        def provider_name
          auth['provider']
        end

        def provider_uid
          auth['uid']
        end

        def provider_access_token
          auth['credentials']['token']
        end

        def profile
          {
            'name' => profile_name,
            'email' => profile_email,
            'location' => profile_location,
            'image' => profile_image
          }
        end

        def profile_name
          info['name']
        end

        def profile_email
          info['email']
        end

        def profile_location
          info['location']
        end

        def profile_image
          info['image']
        end

        def info
          auth['info'].to_hash
        end

        def trace
          {
            'ip' => ip,
            'user_agent' => user_agent,
            'timestamp' => now,
            'platform' => platform,
            'locale' => locale
          }
        end

        def ip
          action_dispatch_remote_ip || env['HTTP_CLIENT_IP'] ||
            env['HTTP_X_REMOTE_ADDR'] || env['REMOTE_ADDR']
        end

        def action_dispatch_remote_ip
          if remote_ip = env['action_dispatch.remote_ip']
            remote_ip.to_s
          end
        end

        def user_agent
          env['HTTP_USER_AGENT']
        end

        def now
          @time.now.to_i.to_s
        end

        def platform
          mobile_user_agent? ? 'mobile' : 'desktop'
        end

        def mobile_user_agent?
          !!mobile_user_agents.match(user_agent)
        end

        def mobile_user_agents
          Regexp.new(MOBILE_USER_AGENTS, true)
        end

        MOBILE_USER_AGENTS =
          'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' \
          'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' \
          'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' \
          'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' \
          'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' \
          'mobile|zune|iphone|android|ipod|ipad'

        def locale
          env['X-Locale']
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
