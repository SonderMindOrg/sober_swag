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

      def lazy_type
        @lazy_type ||= @base.lazy_type.meta(**metadata)
      end

      def type
        @type ||= @base.type.meta(**metadata)
      end

      def finalize_lazy_type!
        @base.finalize_lazy_type!
        # Using .meta on dry-struct returns a *new type* that wraps the old one.
        # As such, we need to be a bit clever about when we tack on the identifier
        # for this type.
        %i[lazy_type type].each do |sym|
          public_send(sym).identifier(@base.public_send(sym).identifier) if @base.public_send(sym).respond_to?(:identifier)
        end
      end

      def lazy_type?
        @base.lazy_type?
      end
    end
  end
end
