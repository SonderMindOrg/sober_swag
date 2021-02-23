module SoberSwag
  module Nodes
    ##
    # @abstract
    # Base Node that all other nodes inherit from.
    # All nodes should define the following:
    #
    #
    # - `#deconstruct`, which returns an array of *everything needed to idenitfy the node.*
    #   We base comparisons on the result of deconstruction.
    # - `#deconstruct_keys`, which returns a hash of *everything needed to identify the node*.
    #   We use this later.
    class Base
      include Comparable

      ##
      # Value-level comparison.
      #
      # @param other [Object] the other object
      # @return [1, 0, -1] if the object is greater than, less than, or equal to the other
      def <=>(other)
        return other.class.name <=> self.class.name unless other.instance_of?(self.class)

        deconstruct <=> other.deconstruct
      end

      ##
      # Is this object equal to the other object?
      # @param other [Object] the object to compare
      # @return [Boolean] yes or no
      def eql?(other)
        deconstruct == other.deconstruct
      end

      ##
      # Standard hash key.
      # @return [Integer]
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
      #
      # @yieldparam node nodes contained within this node, from the bottom-up.
      #   This block will first transform the innermost node, then the second layer, and so on, until we get to the node you originally called `#cata` on.
      # @yieldreturn [Object] the object you wish to transform into.
      def cata
        raise ArgumentError, 'Base is abstract'
      end

      ##
      # Map over the inner, contained type of this node.
      # This will *only* map over values wrapped in a `SoberSwag::Nodes::Primitive` object.
      # Unlike {#cata}, it does not transform the entire node tree.
      def map
        raise ArgumentError, 'Base is abstract'
      end
    end
  end
end
