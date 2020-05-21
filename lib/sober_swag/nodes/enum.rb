module SoberSwag
  module Nodes
    class Enum < Base

      def initialize(values)
        @values = values
      end

      attr_reader :values

      def map(&block)
        self.class.new(@values.map(&block))
      end

      def deconstruct
        [values]
      end

      def deconstruct_keys(keys)
        { values: values }
      end

      def cata(&block)
        block.call(dup)
      end
    end
  end
end
