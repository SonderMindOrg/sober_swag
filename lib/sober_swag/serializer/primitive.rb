module SoberSwag
  module Serializer
    ##
    # A class that does *no* serialization: you give it a type,
    # and it will pass any serialized input on verbatim.
    class Primitive < Base
      def initialize(type)
        @type = type
      end

      attr_reader :type

      def serialize(object, _options = {})
        object
      end
    end
  end
end
