module SoberSwag
  module Reporting
    module Input
      ##
      # Convert booleans.
      class Bool < Base
        def call(val)
          return Report::Value.new(['was not a bool']) unless [true, false].include?(val)

          val
        end

        def swagger_schema
          [{ type: 'boolean' }, {}]
        end
      end
    end
  end
end
