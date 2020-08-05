module SoberSwag
  ##
  # Container module for serializers.
  # The interface for these is described in {SoberSwag::Serializer::Base}.
  module Serializer
    autoload(:Base, 'sober_swag/serializer/base')
    autoload(:Primitive, 'sober_swag/serializer/primitive')
    autoload(:Conditional, 'sober_swag/serializer/conditional')
    autoload(:Array, 'sober_swag/serializer/array')
    autoload(:Mapped, 'sober_swag/serializer/mapped')
    autoload(:Optional, 'sober_swag/serializer/optional')
    autoload(:FieldList, 'sober_swag/serializer/field_list')
    autoload(:Meta, 'sober_swag/serializer/meta')

    class << self
      ##
      # Use a "Primitive" serializer, which *does not* actually do any type-changing, and instead passes
      # in values raw.
      #
      # @param contained {Class} Dry::Type to use
      def primitive(contained)
        SoberSwag::Serializer::Primitive.new(contained)
      end
    end
  end
end
