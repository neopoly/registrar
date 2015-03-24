require 'registrar/mapper/params'

module Registrar
  module Mapper
    class OmniAuth < Params
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
