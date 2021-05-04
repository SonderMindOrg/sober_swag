module SoberSwag
  module Nodes
    ##
    # A List of the contained element types.
    #
    # Unlike {SoberSwag::Nodes::Array}, this actually models arrays.
    # The other one is a node that *is* an array in terms of what it contains.
    # Kinda confusing, but oh well.
    #
    # @todo swap the names of this and {SoberSwag::Nodes::Array} so it's less confusing.
    class List < Base
      ##
      # Initialize with a node representing the type of elements in the list.
      # @param element [SoberSwag::Nodes::Base] the type
      def initialize(element)
        @element = element
      end

      ##
      # @return [SoberSwag::Nodes::Base]
      attr_reader :element

      ##
      # @return [Array(SoberSwag::Nodes::Base)]
      def deconstruct
        [element]
      end

      ##
      # @return [Hash{Symbol => SoberSwag::Nodes::Base}]
      #   the contained type wrapped in an `element:` key.
      def deconstruct_keys(_)
        { element: element }
      end

      ##
      # @see SoberSwag::Nodes::Base#cata
      #
      # Maps over the element type, then this `List` type.
      def cata(&block)
        block.call(
          self.class.new(
            element.cata(&block)
          )
        )
      end

      ##
      # @see SoberSwag::Nodes::Base#map
      #
      # Maps over the element type.
      def map(&block)
        self.class.new(
          element.map(&block)
        )
      end
    end
  end
end
