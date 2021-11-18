module SoberSwag
  ##
  # A new module for parsers with better error reporting.
  module Reporting
    autoload :Input, 'sober_swag/reporting/input'
    autoload :Report, 'sober_swag/reporting/report'
    autoload :Output, 'sober_swag/reporting/output'
    autoload :Compiler, 'sober_swag/reporting/compiler'
  end
end
