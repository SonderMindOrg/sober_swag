module SoberSwag
  module Serializer
    ##
    # Make a serialize of arrays out of a serializer of the elements
    class Array < Base
      def initialize(element_serializer)
        @element_serializer = element_serializer
      end

      def lazy_type?
        @element_serializer.lazy_type?
      end

      def lazy_type
        @element_serializer.lazy_type
      end

      def finalize_lazy_type!
        @element_serializer.finalize_lazy_type!
      end

      attr_reader :element_serializer

      def serialize(object, options = {})
        object.map { |a| element_serializer.serialize(a, options) }
      end

      def type
        SoberSwag::Types::Array.of(element_serializer.type)
      end
    end
  end
end
