module SoberSwag
  module Nodes
    ##
    # Exactly like a {SoberSwag::Nodes::Primitive} node, except it can be null.
    # @todo: make this a boolean parameter of {SoberSwag::Nodes::Primitive}
    class NullablePrimitive < Primitive
    end
  end
end
