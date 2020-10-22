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
      def identifier(arg = nil)
        @identifier = arg if arg

        @identifier || name.to_s.gsub('::', '.')
      end

      def attribute(key, parent = SoberSwag::InputObject, &block)
        raise ArgumentError, "parent class #{parent} is not an input object type!" unless valid_field_def?(parent, block)

        super(key, parent, &block)
      end

      def attribute?(key, parent = SoberSwag::InputObject, &block)
        raise ArgumentError, "parent class #{parent} is not an input object type!" unless valid_field_def?(parent, block)

        super(key, parent, &block)
      end

      def meta(*args)
        original = self

        super(*args).tap do |result|
          return result unless result.is_a?(Class)

          result.define_singleton_method(:alias?) { true }
          result.define_singleton_method(:alias_of) { original }
        end
      end

      ##
      # .primitive is already defined on Dry::Struct, so forward to the superclass if
      # not called as a way to get a primitive type
      def primitive(*args)
        if args.length == 1
          SoberSwag::Types.const_get(args.first)
        else
          super
        end
      end

      def param(sym)
        SoberSwag::Types::Params.const_get(sym)
      end

      private

      def valid_field_def?(parent, block)
        return true if block.nil?

        parent.is_a?(Class) && parent <= SoberSwag::InputObject
      end
    end
  end
end
