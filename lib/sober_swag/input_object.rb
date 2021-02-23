module SoberSwag
  ##
  # A variant of Dry::Struct that allows you to set a "model name" that is publically visible.
  # If you do not set one, it will be the Ruby class name, with any '::' replaced with a '.'.
  #
  # This otherwise behaves exactly like a Dry::Struct.
  # Please see the documentation for that class to see how it works.
  class InputObject < Dry::Struct
    transform_keys(&:to_sym)
    include SoberSwag::Type::Named

    class << self
      ##
      # The name to use for this type in external documentation.
      #
      # @param new_ident [String] what to call this InputObject in external documentation.
      def identifier(new_ident = nil)
        @identifier = new_ident if new_ident

        @identifier || name.to_s.gsub('::', '.')
      end

      ##
      # @overload attribute(key, parent = SoberSwag::InputObject, &block)
      #   Defines an attribute as a direct sub-object.
      #   This block will be called as in {SoberSwag.input_object}.
      #   This might be useful in a case like the following:
      #
      #     class Classroom < SoberSwag::InputObject do
      #       attribute :biographical_detail do
      #         attribute :student_name, primitive(:String)
      #       end
      #     end
      #
      #   @param key [Symbol] the attribute name
      #   @param parent [Class] the parent class to use for the sub-object
      # @overload attribute(key, type)
      #   Defines a new attribute with the given type.
      #   @param key [Symbol] the attribute name
      #   @param type the attribute type
      def attribute(key, parent = SoberSwag::InputObject, &block)
        raise ArgumentError, "parent class #{parent} is not an input object type!" unless valid_field_def?(parent, block)

        super(key, parent, &block)
      end

      ##
      # @overload attribute(key, parent = SoberSwag::InputObject, &block)
      #   Defines an optional attribute by defining a sub-object inline.
      #   This differs from a nil-able attribute as it can be *not provided*, while nilable attributes must be set to `null`.
      #
      #   Yields to the block like in {SoberSwag.input_object}
      #
      #   @param key [Symbol] the attribute name
      #   @param parent [Class] the parent class to use for the sub-object
      # @overload attribute(key, type)
      #   Defines an optional attribute with a given type.
      #   This differs from a nil-able attribute as it can be *not provided*, while nilable attributes must be set to `null`.
      #
      #   @param key [Symbol] the attribute name
      #   @param type the attribute type, another parseable object.
      def attribute?(key, parent = SoberSwag::InputObject, &block)
        raise ArgumentError, "parent class #{parent} is not an input object type!" unless valid_field_def?(parent, block)

        super(key, parent, &block)
      end

      ##
      # Add metadata keys, like `:description`, to the defined type.
      # Note: does NOT mutate the type, returns a new type with the metadata added.
      #
      # @param args [Hash] the argument values
      # @return [SoberSwag::InputObject] the new input object class
      def meta(*args)
        original = self

        super(*args).tap do |result|
          return result unless result.is_a?(Class)

          result.define_singleton_method(:alias?) { true }
          result.define_singleton_method(:alias_of) { original }
        end
      end

      ##
      # Convenience method: you can use `.primitive` get a primitive parser for a given type.
      # This lets you write:
      #
      #   class Foo < SoberSwag::InputObject
      #     attribute :bar, primitive(:String)
      #    end
      #
      # instead of
      #
      #   class Foo < SoberSwag::InputObject
      #     attribute :bar, SoberSwag::Types::String
      #   end
      #
      # @param args [Symbol] a symbol
      # @return a primitive parser
      def primitive(*args)
        if args.length == 1
          SoberSwag::Types.const_get(args.first)
        else
          super
        end
      end

      ##
      # Convenience method: you can use `.param` to get a parameter parser of a given type.
      # Said parsers are more loose: for example, `param(:Integer)` will parse the string `"10"` into `10`, while
      # `primitive(:Integer)` will throw an error.
      #
      # This method lets you write:
      #
      #   class Foo < SoberSwag::InputObject
      #     attribute :bar, param(:Integer)
      #   end
      #
      # instead of
      #
      #   class Foo < SoberSwag::InputObject
      #     attribute :bar, SoberSwag::Types::Param::Integer
      #   end
      #
      # @param name [Symbol] the name of the parameter type to get
      # @return a parameter parser
      def param(name)
        SoberSwag::Types::Params.const_get(name)
      end

      private

      def valid_field_def?(parent, block)
        return true if block.nil?

        parent.is_a?(Class) && parent <= SoberSwag::InputObject
      end
    end
  end
end
