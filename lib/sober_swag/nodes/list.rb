module SoberSwag
  module Nodes
    ##
    # A List of the contained element types.
    #
    # Unlike {SoberSwag::Nodes::Array}, this actually models arrays.
    # The other one is a node that *is* an array in terms of what it contains.
    # Kinda confusing, but oh well.
    class List
      def initialize(element)
        @element = element
      end

      include Comparable

      attr_reader :element

      def <=>(other)
        return self.class.name <=> other.class.name unless self.class == other.class

        element <=> other.element
      end

      def eql?(other)
        self == other
      end

      def hash
        [self.class, element].hash
      end

      def deconstruct
        [element]
      end

      def deconstruct_keys(_)
        { element: element }
      end

      def cata(&block)
        block.call(
          self.class.new(
            element.cata(&block)
          )
        )
      end

      def map(&block)
        self.class.new(
          element.map(&block)
        )
      end

    end
  end
end
