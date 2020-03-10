module SoberSwag
  module Nodes
    ##
    # Swagges uses an array of OneOf types, so we
    # transform our sum nodes into this
    class OneOf < ::SoberSwag::Nodes::Array
      def deconstruct_keys(_)
        { alternatives: @elemenets }
      end
    end
  end
end
