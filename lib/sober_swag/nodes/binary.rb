module SoberSwag
  module Nodes
    ##
    # A
    #
    # It's cool I promise.
    class Binary < Base
      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
      end

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
