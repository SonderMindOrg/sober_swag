module SoberSwag
  class OutputObject
    ##
    # A single field in an output object.
    # Later used to make an actual serializer from this.
    class Field
      ##
      # @param name [Symbol] the name of this field
      # @param serializer [SoberSwag::Serializer::Base, Proc, Lambda] how to serialize
      #   the value in this field.
      #   If given a `Proc` or `Lambda`, the `Proc` or `Lambda` should return
      #   an instance of SoberSwag::Serializer::Base when called.
      # @param from [Symbol] an optional parameter specifying
      #   that this field should be plucked "from" another
      #   attribute of a ruby object
      # @param block [Proc] a proc to get this field from a serialized
      #   object. If not given, will try to grab an attribute
      #   with the same name, *or* with the name of `from:` if that was sent.
      def initialize(name, serializer, from: nil, &block)
        @name = name
        @root_serializer = serializer
        @from = from
        @block = block
      end

      ##
      # @return [Symbol] name of this field.
      attr_reader :name

      ##
      # @return [SoberSwag::Serializer::Base]
      def serializer
        @serializer ||= resolved_serializer.serializer.via_map(&transform_proc)
      end

      ##
      # @return [SoberSwag::Serializer::Base]
      def resolved_serializer
        if @root_serializer.is_a?(Proc)
          @root_serializer.call
        else
          @root_serializer
        end
      end

      private

      ##
      # @return [Proc]
      def transform_proc
        return @transform_proc if defined?(@transform_proc)

        return @transform_proc = @block if @block

        key = @from || @name
        @transform_proc = proc do |object, _|
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
