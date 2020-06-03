module SoberSwag
  module Serializer
    ##
    # A new serializer by mapping over the serialization function
    class Mapped < Base

      def initialize(base, map_f)
        @base = base
        @map_f = map_f
      end

      def serialize(object, options)
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

      ##
      # I have no freaking clue if ruby optimizes proc composition,
      # but we at least save some node traversals here
      def via_map(&block)
        SoberSwag::Serializer::Mapped.new(@base, @map_f >> block)
      end

    end
  end
end
