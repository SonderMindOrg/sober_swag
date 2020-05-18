module SoberSwag
  module Serializer
    class Primitive < Base
      def initialize(type)
        @type = type
      end

      attr_reader :type

      def serialize(object, options = {})
        object
      end
    end
  end
end
