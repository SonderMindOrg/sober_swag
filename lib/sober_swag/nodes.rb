module SoberSwag
  ##
  # Base namespace for all nodes.
  # These nodes are compiled into an actual swagger definition
  # via a catamorphism, which I promise is not nearly as scary as it sounds.
  # Sort of.
  module Nodes
    autoload :Binary, 'sober_swag/nodes/binary'
    autoload :Primitive, 'sober_swag/nodes/primitive'
    autoload :NullablePrimitive, 'sober_swag/nodes/nullable_primitive'
    autoload :Sum, 'sober_swag/nodes/sum'
    autoload :Array, 'sober_swag/nodes/array'
    autoload :Object, 'sober_swag/nodes/object'
    autoload :Attribute, 'sober_swag/nodes/attribute'
    autoload :OneOf, 'sober_swag/nodes/one_of'
    autoload :List, 'sober_swag/nodes/list'
  end
end
