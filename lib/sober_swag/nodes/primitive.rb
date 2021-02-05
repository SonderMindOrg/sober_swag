module SoberSwag
  module Nodes
    ##
    # Root node of the tree.
    # This contains "primitive values."
    # Initially, this is probably the types of attributes or array elements or whatever.
    # As we use {#cata} to transform this, it will start containing swagger-compatible type objects.
    #
    # This node can contain metadata as well.
    class Primitive < Base
      ##
      # @param value [Object] the primitive value to store
      # @param metadata [Hash] the metadata
      def initialize(value, metadata = {})
        @value = value
        @metadata = metadata
      end

      ##
      # @return [Object] the contained value
      attr_reader :value

      ##
      # @return [Hash] metadata associated with the contained value.
      attr_reader :metadata

      ##
      # @see SoberSwag::Nodes::Base#map
      #
      # This will actually map over {#value}.
      def map(&block)
        self.class.new(block.call(value), metadata.dup)
      end

      ##
      # Deconstructs to the value and the metadata.
      #
      # @return [Array(Object, Hash)] containd value and metadata.
      def deconstruct
        [value, metadata]
      end

      ##
      # Wraps the attributes in a hash.
      #
      # @return [Hash(Symbol => Object, Hash)] {#value} in `value:`, {#metadata} in `metadata:`
      def deconstruct_keys(_)
        { value: value, metadata: metadata }
      end

      ##
      # @see SoberSwag::Nodes::Base#cata
      # As this is a root node, we actually call the block directly.
      # @yieldparam node [SoberSwag::Nodes::Primitive] this node.
      # @return whatever the block returns.
      def cata(&block)
        block.call(self.class.new(value, metadata))
      end
    end
  end
end
