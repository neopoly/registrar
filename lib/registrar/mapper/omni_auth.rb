require 'registrar/adapter/params'

module Registrar
  module Mapper
    class OmniAuth < Adapter::Params
      def initialize(app)
        super(app, mapping)
      end

      private

      def mapping
        {
          "profile#name" => "name",
          "profile#email" => "email"
        }
      end
    end
  end
end
