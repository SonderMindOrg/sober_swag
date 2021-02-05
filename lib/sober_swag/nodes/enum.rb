module SoberSwag
  module Nodes
    ##
    # Compiler node to represent an enum value.
    # Enums are special enough to have their own node, as they are basically a constant list of always-string values.
    class Enum < Base
      def initialize(values)
        @values = values
      end

      ##
      # @return [Array<Symbol,String>] values of the enum.
      attr_reader :values

      ##
      # Since there is nothing to map over, this node will never actually call the block given.
      #
      # @see SoberSwag::Nodes::Base#map
      def map
        dup
      end

      ##
      # Deconstructs into the enum values.
      #
      # @return [Array(Array<Symbol,String>)] the cases of the enum.
      def deconstruct
        [values]
      end

      ##
      # @return [Hash<Symbol => Array<Symbol,String>>] the values, wrapped in a `values:` key.
      def deconstruct_keys(_keys)
        { values: values }
      end

      ##
      # @see SoberSwag::Nodes::Base#cata
      def cata(&block)
        block.call(dup)
      end
    end
  end
end
