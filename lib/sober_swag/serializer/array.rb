module SoberSwag
  module Serializer
    ##
    # Transform a serializer that works on elements to one that works on Arrays
    class Array < Base
      ##
      # Make an array serializer out of another serializer.
      # @param element_serializer [SoberSwag::Serializer::Base] the serializer to use for each element.
      def initialize(element_serializer)
        @element_serializer = element_serializer
      end

      ##
      # The serializer that will be used for each element in the array.
      #
      # @return [SoberSwag::Serializer::Base]
      attr_reader :element_serializer

      ##
      # Delegates to {#element_serializer}
      def lazy_type?
        @element_serializer.lazy_type?
      end

      ##
      # Delegates to {#element_serializer}, wrapped in an array
      def lazy_type
        SoberSwag::Types::Array.of(@element_serializer.lazy_type)
      end

      ##
      # Delegates to {#element_serializer}
      def finalize_lazy_type!
        @element_serializer.finalize_lazy_type!
      end

      ##
      # Serialize an array of objects that can be serialized with {#element_serializer}
      # by calling `element_serializer.serialize` for each item in this array.
      #
      # Note: since ruby is duck-typed, anything that responds to {#map} should work!
      #
      # @param object [Array<Object>,#map] collection of objects to serialize
      # @return [Array<Object>] JSON-compatible array
      def serialize(object, options = {})
        object.map { |a| element_serializer.serialize(a, options) }
      end

      ##
      # The type of items returned from {#serialize}
      def type
        SoberSwag::Types::Array.of(element_serializer.type)
      end
    end
  end
end
