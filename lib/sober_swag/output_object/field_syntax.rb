module SoberSwag
  class OutputObject
    ##
    # Syntax for definitions that can add fields.
    module FieldSyntax
      def field(name, serializer, from: nil, &block)
        add_field!(Field.new(name, serializer, from: from, &block))
      end

      ##
      # Given a symbol to this, we will use a primitive name
      def primitive(name)
        SoberSwag::Serializer.primitive(SoberSwag::Types.const_get(name))
      end
    end
  end
end
