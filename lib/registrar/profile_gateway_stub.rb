module Registrar
  class ProfileGatewayStub
    def call(auth_hash)
      Profile.new(auth_hash)
    end

    class Profile
      def initialize(auth_hash)
        provider_name = auth_hash['provider']['name']
        uid = auth_hash['provider']['uid']

        @internal_uid = 1
        @external_uid = "#{provider_name}_#{uid}"
        @name = auth_hash['profile']['name']
      end

      def to_hash
        {
          :internal_uid => @internal_uid,
          :external_uid => @external_uid,
          :access_token => 'verified',
          :name => @name
        }
      end
    end
  end
end
