module SoberSwag
  module Nodes
    ##
    # Base class for nodes that contain arrays of other nodes.
    # This is very different from an attribute representing a node which *is* an array of some element type!!
    class Array
      def initialize(elements)
        @elements = elements
      end

      include Comparable

      def <=>(other)
        return other.class.name <=> self.class.name unless other.class == self.class

        @elements <=> other.elements
      end

      def eql?(other)
        self == other
      end

      def hash
        elements.hash
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
