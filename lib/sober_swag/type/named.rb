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
        def alias?
          false
        end

        def alias_of
          nil
        end

        def root_alias
          alias_of || self
        end

        def description(arg = nil)
          @description = arg if arg
          @description
        end
      end

      def self.included(mod)
        mod.extend(ClassMethods)
      end
    end
  end
end
