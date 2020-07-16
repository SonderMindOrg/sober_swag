module SoberSwag
  module Serializer
    ##
    # Given something that serializes a type 'A',
    # this can be used to make a serializer of type 'A | nil'.
    #
    # Or, put another way, makes serializers not crash on nil values.
    class Optional < Base
      def initialize(inner)
        @inner = inner
      end

      attr_reader :inner

      def lazy_type?
        @inner.lazy_type?
      end

      def lazy_type
        @inner.lazy_type.optional
      end

      def finalize_lazy_type!
        @inner.finalize_lazy_type!
      end

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
