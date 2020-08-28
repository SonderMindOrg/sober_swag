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

      def meta(*args)
        original = self

        super(*args).tap do |result|
          return result unless result.is_a?(Class)

          result.define_singleton_method(:alias?) { true }
          result.define_singleton_method(:alias_of) { original }
        end
      end

      def primitive(sym)
        SoberSwag::Types.const_get(sym)
      end

      def param(sym)
        SoberSwag::Types::Params.const_get(sym)
      end
    end
  end
end
