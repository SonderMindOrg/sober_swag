module SoberSwag
  module Reporting
    ##
    # Module for SoberSwag reporting inputs.
    module Input
      autoload :Base, 'sober_swag/reporting/input/base'
      autoload :Bool, 'sober_swag/reporting/input/bool'
      autoload :Converting, 'sober_swag/reporting/input/converting'
      autoload :Described, 'sober_swag/reporting/input/described'
      autoload :Dictionary, 'sober_swag/reporting/input/dictionary'
      autoload :Defer, 'sober_swag/reporting/input/defer'
      autoload :Enum, 'sober_swag/reporting/input/enum'
      autoload :Either, 'sober_swag/reporting/input/either'
      autoload :Format, 'sober_swag/reporting/input/format'
      autoload :Number, 'sober_swag/reporting/input/number'
      autoload :Interface, 'sober_swag/reporting/input/interface'
      autoload :InRange, 'sober_swag/reporting/input/in_range'
      autoload :List, 'sober_swag/reporting/input/list'
      autoload :MultipleOf, 'sober_swag/reporting/input/multiple_of'
      autoload :Mapped, 'sober_swag/reporting/input/mapped'
      autoload :MergeObjects, 'sober_swag/reporting/input/merge_objects'
      autoload :Null, 'sober_swag/reporting/input/null'
      autoload :Object, 'sober_swag/reporting/input/object'
      autoload :Pattern, 'sober_swag/reporting/input/pattern'
      autoload :Referenced, 'sober_swag/reporting/input/referenced'
      autoload :Struct, 'sober_swag/reporting/input/struct'
      autoload :Text, 'sober_swag/reporting/input/text'

      class << self
        ##
        # @return [SoberSwag::Reporting::Input::Bool]
        def bool
          Bool.new
        end

        ##
        # @return [SoberSwag::Reporting::Input::Text]
        def text
          Text.new
        end

        ##
        # @return [SoberSwag::Reporting::Input::Number]
        def number
          Number.new
        end

        ##
        # @return [SoberSwag::Reporting::Input::Null]
        def null
          Null.new
        end
      end
    end
  end
end
