module SoberSwag
  module Serializer
    ##
    # A new serializer by mapping over the serialization function
    class Mapped < Base
      ##
      # Create a new mapped serializer.
      # @param base [SoberSwag::Serializer::Base] a serializer to use after mapping
      # @param map_f [Proc,Lambda] a mapping function to use before serialization
      def initialize(base, map_f)
        @base = base
        @map_f = map_f
      end

      ##
      # @return [SoberSwag::Serializer::Base] serializer to use after mapping
      attr_reader :base
      ##
      # @return [Proc, Lambda, #call] function to use before serialization
      attr_reader :map_f

      def serialize(object, options = {})
        @base.serialize(@map_f.call(object), options)
      end

      def lazy_type?
        @base.lazy_type?
      end

      def lazy_type
        @base.lazy_type
      end

      def finalize_lazy_type!
        @base.finalize_lazy_type!
      end

      def type
        @base.type
      end
    end
  end
end
