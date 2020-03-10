module SoberSwag
  module Nodes
    ##
    # Root node of the tree
    class Primitive
      def initialize(value)
        @value = value
      end

      include Comparable

      attr_reader :value

      def map(&block)
        self.class.new(block.call(value))
      end

      def hash
        value.hash
      end

      def eql?(other)
        other == self
      end

      def <=>(other)
        return self.class.name <=> other.class.name unless self.class == other.class

        value <=> other.value
      end

      def deconstruct
        [value]
      end

      def deconstruct_keys(_)
        { value: value }
      end

      def cata(&block)
        block.call(self.class.new(value))
      end
    end
  end
end
