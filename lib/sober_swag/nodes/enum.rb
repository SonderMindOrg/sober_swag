module SoberSwag
  module Nodes
    ##
    # Compiler node to represent an enum value.
    # Enums are special enough to have their own node.
    class Enum < Base
      def initialize(values)
        @values = values
      end

      attr_reader :values

      def map
        dup
      end

      def deconstruct
        [values]
      end

      def deconstruct_keys(_keys)
        { values: values }
      end

      def cata(&block)
        block.call(dup)
      end
    end
  end
end
