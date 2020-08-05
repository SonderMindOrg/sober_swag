module SoberSwag
  module Nodes
    ##
    # Base Node that all other nodes inherit from.
    # All nodes should define the following:
    #
    # - #deconstruct, which returns an array of *everything needed to idenitfy the node.*
    #   We base comparisons on the result of deconstruction.
    # - #deconstruct_keys, which returns a hash of *everything needed to identify the node*.
    #   We use this later.
    class Base
      include Comparable

      ##
      # Value-level comparison.
      def <=>(other)
        return other.class.name <=> self.class.name unless other.class == self.class

        deconstruct <=> other.deconstruct
      end

      def eql?(other)
        deconstruct == other.deconstruct
      end

      def hash
        deconstruct.hash
      end

      ##
      # Perform a catamorphism, or, a deep-first recursion.
      #
      # The basic way this works is deceptively simple: When you use 'cata' on a node,
      # it will call the block you gave it with the *deepest* nodes in the tree first.
      # It will then use the result of that block to reconstruct their *parent* node, and then
      # *call cata again* on the parent, and so on until we reach the top.
      #
      # When working with these definition nodes, we very often want to transform something recursively.
      # This method allows us to do so by focusing on a single level at a time, keeping the actual recursion *abstract*.
      def cata
        raise ArgumentError, 'Base is abstract'
      end

      def map
        raise ArgumentError, 'Base is abstract'
      end

      def flatten_one_ofs
        raise ArgumentError, 'Base is abstract'
      end
    end
  end
end
