module SoberSwag
  module Serializer
    ##
    # Given something that serializes a type 'A',
    # this can be used to make a serializer of type 'A | nil'.
    #
    # Or, put another way, makes serializers not crash on nil values.
    # If {#serialize} is passed nil, it will return `nil` immediately, and not
    # try to call the serializer of {#inner}.
    class Optional < Base
      ##
      # An error thrown when trying to nest optional serializers.
      class NestedOptionalError < Error; end
      ##
      # @param inner [SoberSwag::Serializer::Base] the serializer to use for non-nil values
      def initialize(inner)
        @inner = inner
      end

      ##
      # @return [SoberSwag::Serializer::Base] the serializer to use for non-nil values.
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

      ##
      # If `object` is nil, return `nil`.
      # Otherwise, call `inner.serialize(object, options)`.
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

      ##
      # Since nesting optional types is bad, this will always raise an ArgumentError
      #
      # @raise [NestedOptionalError] always
      # @return [void] nothing, always raises.
      def optional(*)
        raise NestedOptionalError, 'no nesting optionals please'
      end
    end
  end
end
