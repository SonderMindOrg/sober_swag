module SoberSwag
  module Nodes
    ##
    # Root node of the tree
    class Primitive < Base
      def initialize(value)
        @value = value
      end

      attr_reader :value

      def map(&block)
        self.class.new(block.call(value))
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
