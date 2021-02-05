module SoberSwag
  module Nodes
    ##
    # Exactly like a {SoberSwag::Nodes::Primitive} node, except it can be null.
    # @todo: make this a boolean parameter of {SoberSwag::Nodes::Primtive}
    class NullablePrimitive < Primitive
    end
  end
end
