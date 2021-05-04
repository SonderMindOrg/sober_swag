module SoberSwag
  module Type
    ##
    # Mixin module used to identify types that should be considered
    # standalone, named types from SoberSwag's perspective.
    module Named
      ##
      # Class Methods Module.
      # Modules that include {SoberSwag::Type::Named}
      # will automatically extend this module.
      module ClassMethods
        ##
        # Is this type a "wrapper" for another type?
        def alias?
          false
        end

        ##
        # The type this type is a wrapper for
        def alias_of
          nil
        end

        ##
        # The "root" type along the alias chain
        def root_alias
          alias_of || self
        end

        ##
        # @overload description()
        #   @return [String] a human-readable description of this type
        # @overload description(arg)
        #   @param arg [String] a human-readable description of this type
        #   @return [String] `arg`
        def description(arg = nil)
          @description = arg if arg
          @description
        end
      end

      ##
      # When included, extends {SoberSwag::Type::Named::ClassMethods}
      def self.included(mod)
        mod.extend(ClassMethods)
      end
    end
  end
end
