module SoberSwag
  module Nodes
    ##
    # Extremely basic binary node base class!
    #
    # It's cool I promise.
    class Binary
      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
      end

      include Comparable

      attr_reader :lhs, :rhs
      ##
      # Map the root values of the node.
      # This just calls map on the lhs and the rhs
      def map(&block)
        self.class.new(
          lhs.map(&block),
          rhs.map(&block)
        )
      end

      def <=>(other)
        return self.class.name <=> other.class.name unless self.class == other.class

        deconstruct <=> other.deconstruct
      end

      def eql?(other)
        self == other
      end

      def hash
        deconstruct.hash
      end

      def deconstruct
        [lhs, rhs]
      end

      def deconstruct_keys(keys)
        { lhs: lhs, rhs: rhs }
      end

      ##
      # Perform a catamorphism on this node.
      def cata(&block)
        block.call(
          self.class.new(
            lhs.cata(&block),
            rhs.cata(&block)
          )
        )
      end
    end
  end
end
