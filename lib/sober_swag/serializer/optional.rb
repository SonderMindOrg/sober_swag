module SoberSwag
  module Serializer
    class Optional < Base

      def initialize(inner)
        @inner = inner
      end

      attr_reader :inner

      def serialize(object, options = {})
        if object.nil?
          object
        else
          inner.serialize(object, options)
        end
      end

      def type
        inner.type.optional
      end

      def optional(*)
        raise ArgumentError, 'no nesting optionals please'
      end

    end
  end
end
