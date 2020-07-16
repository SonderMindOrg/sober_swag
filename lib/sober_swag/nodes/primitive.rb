module SoberSwag
  module Nodes
    ##
    # Root node of the tree
    class Primitive < Base
      def initialize(value, metadata = {})
        @value = value
        @metadata = metadata
      end

      attr_reader :value, :metadata

      def map(&block)
        self.class.new(block.call(value))
      end

      def deconstruct
        [value, metadata]
      end

      def deconstruct_keys(_)
        { value: value, metadata: metadata }
      end

      def cata(&block)
        block.call(self.class.new(value, metadata))
      end
    end
  end
end
