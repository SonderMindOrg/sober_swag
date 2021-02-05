module SoberSwag
  module Nodes
    ##
    # A binary node: has a left and right hand side.
    # Basically a node of a binary tree.
    class Binary < Base
      ##
      # @param lhs [SoberSwag::Nodes::Base] the left-hand node.
      # @param rhs [SoberSwag::Nodes::Base] the right-hand node.
      def initialize(lhs, rhs)
        @lhs = lhs
        @rhs = rhs
      end

      ##
      # @return [SoberSwag::Nodes::Base] the left-hand node
      attr_reader :lhs

      ##
      # @return [SoberSwag::Nodes::Base] the right-hand node
      attr_reader :rhs

      ##
      # Deconstructs into an array of `[lhs, rhs]`
      #
      # @return [Array(SoberSwag::Nodes::Base, SoberSwag::Nodes::Base)]
      def deconstruct
        [lhs, rhs]
      end

      ##
      # Deconstruct into a hash of attributes.
      def deconstruct_keys(_keys)
        { lhs: lhs, rhs: rhs }
      end

      ##
      # @see SoberSwag::Nodes::Base#cata
      #
      # Maps over the LHS side first, then the RHS side, then the root.
      def cata(&block)
        block.call(
          self.class.new(
            lhs.cata(&block),
            rhs.cata(&block)
          )
        )
      end

      ##
      # @see SoberSwag::Nodes::Base#map
      #
      # Maps over the LHS side first, then the RHS side, then the root.
      def map(&block)
        self.class.new(
          lhs.map(&block),
          rhs.map(&block)
        )
      end
    end
  end
end
