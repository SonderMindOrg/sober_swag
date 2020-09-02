module SoberSwag
  module Nodes
    ##
    # One attribute of an object.
    class Attribute < Base
      def initialize(key, required, value, meta = {})
        @key = key
        @required = required
        @value = value
        @meta = meta
      end

      def deconstruct
        [key, required, value, meta]
      end

      def deconstruct_keys
        { key: key, required: required, value: value, meta: meta }
      end

      attr_reader :key, :required, :value, :meta

      def map(&block)
        self.class.new(key, required, value.map(&block), meta)
      end

      def cata(&block)
        block.call(self.class.new(key, required, value.cata(&block), meta))
      end
    end
  end
end
