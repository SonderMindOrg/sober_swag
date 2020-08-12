module SoberSwag
  module Serializer
    ##
    # A new serializer by mapping over the serialization function
    class Mapped < Base
      def initialize(base, map_f)
        @base = base
        @map_f = map_f
      end

      attr_reader :base, :map_f

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
