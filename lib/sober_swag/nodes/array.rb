module SoberSwag
  module Nodes
    ##
    # Base class for nodes that contain arrays of other nodes.
    # This is very different from an attribute representing a node which *is* an array of some element type!!
    class Array < Base
      def initialize(elements)
        @elements = elements
      end

      attr_reader :elements

      ##
      # @see SoberSwag::Nodes::Array#map
      #
      def map(&block)
        self.class.new(elements.map { |elem| elem.map(&block) })
      end

      ##
      # @see SoberSwag::Nodes::Array#cata
      #
      # The block will be called with each element contained in this array node in turn, then called with a `SoberSwag::Nodes::Array` constructed
      # from the resulting values.
      #
      # @return whatever the block yields.
      def cata(&block)
        block.call(self.class.new(elements.map { |elem| elem.cata(&block) }))
      end

      ##
      # Deconstructs into the elements.
      #
      # @return [Array<SoberSwag::Nodes::Base>]
      def deconstruct
        @elements
      end

      ##
      # Deconstruction for pattern-matching: returns a hash with the elements in the `:elements` key.
      # @return [Hash<Symbol => Array<SoberSwag::Nodes::Base>>]
      def deconstruct_keys(_keys)
        { elements: @elements }
      end
    end
  end
end
