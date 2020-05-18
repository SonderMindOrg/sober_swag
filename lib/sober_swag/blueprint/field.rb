module SoberSwag
  class Blueprint
    class Field
      def initialize(name, serializer, from: nil, &block)
        @name = name
        @root_serializer = serializer
        @from = from
        @block = block
      end

      attr_reader :name

      def serializer
        @serializer ||= @root_serializer.via_map(&transform_proc)
      end

      private

      def transform_proc
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
