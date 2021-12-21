module SoberSwag
  module Reporting
    module Output
      ##
      # Base type for simple outputs.
      class Base
        include Interface

        ##
        # Acceptable views to use with this output.
        #
        # @return [Set<Symbol>] the views
        def views
          %i[base].to_set
        end

        def view(view_key)
          return self if view_key == :base

          raise ArgumentError, "#{view_key} is not a view" unless views.include?(view_key)
        end
      end
    end
  end
end
