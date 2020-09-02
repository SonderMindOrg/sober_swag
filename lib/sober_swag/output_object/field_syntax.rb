module SoberSwag
  class OutputObject
    ##
    # Syntax for definitions that can add fields.
    module FieldSyntax
      def field(name, serializer, from: nil, &block)
        add_field!(Field.new(name, serializer, from: from, &block))
      end

      ##
      # Similar to #field, but adds multiple at once.
      # Named #multi because #fields was already taken.
      def multi(names, serializer)
        names.each { |name| field(name, serializer) }
      end

      ##
      # Given a symbol to this, we will use a primitive name
      def primitive(name)
        SoberSwag::Serializer.primitive(SoberSwag::Types.const_get(name))
      end

      ##
      # Merge in anything that has a list of fields, and use it.
      # Note that merging in a full blueprint *will not* also merge in views, just fields defined on the base.
      def merge(other)
        other.fields.each do |field|
          add_field!(field)
        end
      end
    end
  end
end
