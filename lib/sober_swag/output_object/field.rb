module SoberSwag
  class OutputObject
    ##
    # A single field in an output object.
    # Later used to make an actual serializer from this.
    class Field
      def initialize(name, serializer, from: nil, &block)
        @name = name
        @root_serializer = serializer
        @from = from
        @block = block
      end

      attr_reader :name

      def serializer
        @serializer ||= resolved_serializer.serializer.via_map(&transform_proc)
      end

      def resolved_serializer
        if @root_serializer.is_a?(Proc)
          @root_serializer.call
        else
          @root_serializer
        end
      end

      private

      def transform_proc # rubocop:disable Metrics/MethodLength
        if @block
          @block
        else
          key = @from || @name
          proc do |object, _|
            if object.respond_to?(key)
              object.public_send(key)
            else
              object[key]
            end
          end
        end
      end
    end
  end
end
