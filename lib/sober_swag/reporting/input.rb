module SoberSwag
  module Reporting
    ##
    # Module for SoberSwag reporting inputs.
    module Input
      autoload :Base, 'sober_swag/reporting/input/base'
      autoload :Defer, 'sober_swag/reporting/input/defer'
      autoload :Either, 'sober_swag/reporting/input/either'
      autoload :Interface, 'sober_swag/reporting/input/interface'
      autoload :List, 'sober_swag/reporting/input/list'
      autoload :Mapped, 'sober_swag/reporting/input/mapped'
      autoload :Null, 'sober_swag/reporting/input/null'
      autoload :Object, 'sober_swag/reporting/input/object'
      autoload :Pattern, 'sober_swag/reporting/input/pattern'
      autoload :Referenced, 'sober_swag/reporting/input/referenced'
      autoload :Struct, 'sober_swag/reporting/input/struct'
      autoload :Text, 'sober_swag/reporting/input/text'
    end
  end
end
