module SoberSwag
  module Reporting
    ##
    # Reporting outputs.
    #
    # These outputs can tell you what their acceptable views are.
    module Output
      autoload(:Base, 'sober_swag/reporting/output/base')
      autoload(:Defer, 'sober_swag/reporting/output/defer')
      autoload(:Interface, 'sober_swag/reporting/output/interface')
      autoload(:Text, 'sober_swag/reporting/output/text')
      autoload(:ViaMap, 'sober_swag/reporting/output/via_map')
      autoload(:Struct, 'sober_swag/reporting/output/struct')
      autoload(:Referenced, 'sober_swag/reporting/output/referenced')
      autoload(:Object, 'sober_swag/reporting/output/object')
      autoload(:MergeObjects, 'sober_swag/reporting/output/merge_objects')
      autoload(:Viewed, 'sober_swag/reporting/output/viewed')
      autoload(:List, 'sober_swag/reporting/output/list')
      autoload(:Described, 'sober_swag/reporting/output/described')
    end
  end
end
