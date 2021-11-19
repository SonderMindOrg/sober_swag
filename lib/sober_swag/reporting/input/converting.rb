module SoberSwag
  module Reporting
    module Input
      ##
      # Namespace for things that can do conversion.
      # These are really just compound types that kinda look nice.
      module Converting
        autoload(:Decimal, 'sober_swag/reporting/input/converting/decimal')
        autoload(:Date, 'sober_swag/reporting/input/converting/date')
        autoload(:DateTime, 'sober_swag/reporting/input/converting/date_time')
        autoload(:Bool, 'sober_swag/reporting/input/converting/bool')
      end
    end
  end
end
