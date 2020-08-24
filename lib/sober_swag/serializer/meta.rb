module SoberSwag
  module Serializer
    ##
    # Provides metadata on a serializer.
    # All actions delegate to the base.
    class Meta < Base
      def initialize(base, meta)
        @base = base
        @metadata = meta
        @identifier = @base.identifier
      end

      attr_reader :base, :metadata

      def serialize(args, opts = {})
        base.serialize(args, opts)
      end

      def meta(hash)
        self.class.new(base, metadata.merge(hash))
      end

      ##
      # Delegates to `base`, adds metadata, pumbs identifiers
      def lazy_type
        @base.lazy_type.meta(**metadata).tap { |t| t.identifier(@base.identifier) }
      end

      ##
      # Delegates to `base`, adds metadata, plumbs identifiers
      def type
        @base.type.meta(**metadata).tap { |t| t.identifier(@base.identifier) }
      end

      def finalize_lazy_type!
        @base.finalize_lazy_type!
      end

      def lazy_type?
        @base.lazy_type?
      end
    end
  end
end
