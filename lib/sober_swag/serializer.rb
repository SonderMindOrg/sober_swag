module SoberSwag
  module Serializer
    autoload(:Base, 'sober_swag/serializer/base')
    autoload(:Primitive, 'sober_swag/serializer/primitive')
    autoload(:Conditional, 'sober_swag/serializer/conditional')
    autoload(:FieldList, 'sober_swag/serializer/field_list')

    class << self
      ##
      # Use a "Primitive" serializer, which *does not* actually do any type-changing, and instead passes
      # in values raw.
      #
      # @param contained {Class} Dry::Type to use
      def Primitive(contained)
        SoberSwag::Serializer::Primitive.new(contained)
      end
    end

  end
end
