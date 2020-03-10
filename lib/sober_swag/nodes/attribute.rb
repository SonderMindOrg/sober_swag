module SoberSwag
  module Nodes
    ##
    # One attribute of an object.
    class Attribute
      def initialize(key, required, value)
        @key = key
        @required = required
        @value = value
      end

      include Comparable

      def <=>(other)
        return other.class.name <=> self.class.name unless other.class == self.class

        deconstruct <=> other.deconstruct
      end

      def eql?(other)
        self == other
      end

      def hash
        deconstruct.hash
      end

      def deconstruct
        [key, required, value]
      end

      def deconstruct_keys
        { key: key, required: required, value: value }
      end

      attr_reader :key, :required, :value

      def map(&block)
        self.class.new(key, required, value.map(&block))
      end

      def cata(&block)
        block.call(self.class.new(key, required, value.cata(&block)))
      end
    end
  end
end
