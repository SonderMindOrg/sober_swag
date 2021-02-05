module SoberSwag
  module Nodes
    ##
    # A "Sum" type represents either one type or the other.
    #
    # It is called "Sum" because, if a type can be either type `A` or type `B`,
    # the number of possible values for the type of `number_of_values(A) + number_of_values(B)`.
    #
    # Interally, this is primarily used when an object can be either one type or another.
    # It will latter be flattened into {SoberSwag::Nodes::OneOf}
    class Sum < Binary
    end
  end
end
