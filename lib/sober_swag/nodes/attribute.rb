module SoberSwag
  module Nodes
    ##
    # This is a node for one attribute of an object.
    # An object type is represented by a `SoberSwag::Nodes::Object` full of these keys.
    #
    #
    class Attribute < Base
      ##
      # @param key [Symbol] the key of this attribute
      # @param required [Boolean] if this attribute must be set or not
      # @param value [Class] the type of this attribute
      # @param meta [Hash] the metadata associated with this attribute
      def initialize(key, required, value, meta = {})
        @key = key
        @required = required
        @value = value
        @meta = meta
      end

      ##
      # Deconstructs into attributes.
      #
      # @return [Array(Symbol, Boolean, Class, Hash)] the attributes of this object
      def deconstruct
        [key, required, value, meta]
      end

      ##
      # Deconstructs into the attributes as a hash.
      # @param keys [void] ignored
      # @return [Hash] the attributes as keys.
      def deconstruct_keys(_keys)
        { key: key, required: required, value: value, meta: meta }
      end

      ##
      # @return [Symbol]
      attr_reader :key

      ##
      # @return [Boolean] true if this attribute must be set, false otherwise.
      attr_reader :required

      ##
      # @return [Class] the type of this attribute
      attr_reader :value

      ##
      # @return [Hash] the metadata for this attribute.
      attr_reader :meta

      ##
      # @see SoberSwag::Nodes::Base#map
      def map(&block)
        self.class.new(key, required, value.map(&block), meta)
      end

      ##
      # @see SoberSwag::Nodes::Base#cata
      def cata(&block)
        block.call(self.class.new(key, required, value.cata(&block), meta))
      end
    end
  end
end
