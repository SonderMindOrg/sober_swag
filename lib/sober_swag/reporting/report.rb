module SoberSwag
  module Reporting
    ##
    # Namespace modules for the various "reporters," or things that provide error handling.
    module Report
      autoload :Base, 'sober_swag/reporting/report/base'
      autoload :Either, 'sober_swag/reporting/report/either'
      autoload :Error, 'sober_swag/reporting/report/error'
      autoload :Object, 'sober_swag/reporting/report/object'
      autoload :MergedObject, 'sober_swag/reporting/report/merged_object'
      autoload :Value, 'sober_swag/reporting/report/value'
      autoload :List, 'sober_swag/reporting/report/list'
    end
  end
end
