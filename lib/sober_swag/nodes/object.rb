module SoberSwag
  module Nodes
    ##
    # Objects might have attribute keys, so they're
    # basically a list of attributes.
    class Object < SoberSwag::Nodes::Array
      ##
      # @return [Hash{Symbol => Array<SoberSwag::Nodes::Attribute>}]
      #   the attributes, wrapped in an `attributes:` key.
      def deconstruct_keys(_)
        { attributes: @elements }
      end
    end
  end
end
