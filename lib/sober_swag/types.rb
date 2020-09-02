module SoberSwag
  ##
  # Container for types.
  # You can use constants like SoberSwag::Types::Integer and things as a result of this module existing.
  class Types
    include ::Dry::Types()

    autoload(:CommaArray, 'sober_swag/types/comma_array')
  end
end
