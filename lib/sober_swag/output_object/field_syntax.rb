module SoberSwag
  class OutputObject
    ##
    # Syntax for definitions that can add fields.
    module FieldSyntax
      ##
      # Defines a new field.
      # @see SoberSwag::OutputObject::Field#initialize
      # @param name [Symbol] name of this field
      # @param serializer [SoberSwag::Serializer::Base] serializer to use for this field.
      # @param from [Symbol] method name to extract this field from, for convenience.
      # @param block [Proc] optional way to extract this field.
      def field(name, serializer, from: nil, &block)
        add_field!(Field.new(name, serializer, from: from, &block))
      end

      ##
      # Similar to #field, but adds multiple at once.
      # Named #multi because #fields was already taken.
      #
      # @param names [Array<Symbol>] the field names to add.
      # @param serializer [SoberSwag::Serializer::Base] the serializer to use for all fields.
      def multi(names, serializer)
        names.each { |name| field(name, serializer) }
      end

      ##
      # Given a symbol to this, we will use a primitive name
      # @param name [Symbol] symbol to look up.
      # @return [SoberSwag::Serializer::Base] serializer to use.
      def primitive(name)
        SoberSwag::Serializer.primitive(SoberSwag::Types.const_get(name))
      end

      ##
      # Merge in anything that has a list of fields, and use it.
      # Note that merging in a full output object *will not* also merge in views, just fields defined on the base.
      #
      # @param other [#fields] a field container, like a {SoberSwag::OutputObject} or something
      # @param opts [Hash] accepts a key of :except to optionally exclude a field from the output object being merged
      # @return [void]
      def merge(other, opts = {})
        other.fields.each do |field|
          add_field!(field) unless opts.fetch(:except, []).include?(field.name)
        end
      end
    end
  end
end
