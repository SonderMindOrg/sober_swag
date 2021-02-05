module SoberSwag
  module Nodes
    ##
    # OpenAPI v3 represents types that are a "choice" betweeen multiple alternatives as an array.
    # However, it is easier to model these as a sum type initially: if a type can be either an `A`, a `B`, or a `C`, we can modelt this as:
    #
    # `Sum.new(A, Sum.new(B, C))`.
    #
    # This means we only ever need to deal with two types at once.
    # So, we initially serialize to a sum type, then later transform to this array type for further serialization.
    class OneOf < ::SoberSwag::Nodes::Array
      ##
      # @return [Hash<Symbol => SoberSwag::Nodes::Base>] the alternatives, wrapped in an `alternatives:` key.
      def deconstruct_keys(_)
        { alternatives: @elemenets }
      end
    end
  end
end
