module SoberSwag
  module Serializer
    class Primitive < Base
      ##
      # Primtive Serializers don't actually do any serialization.
      # So, we use this extractor proc in all of them, which just returns the passed value.
      EXTRACTION_PROC = proc { |o, _| o }

      def initialize(type)
        @type = type
      end

      def extraction
        EXTRACTION_PROC
      end

    end
  end
end
