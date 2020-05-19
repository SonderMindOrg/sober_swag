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

      def map(&block)
        self.class.new(elements.map { |elem| elem.map(&block) })
      end

      def cata(&block)
        block.call(self.class.new(elements.map { |elem| elem.cata(&block) }))
      end

      def deconstruct
        @elements
      end

      def deconstruct_keys(keys)
        { elements: @elements }
      end
    end
  end
end
