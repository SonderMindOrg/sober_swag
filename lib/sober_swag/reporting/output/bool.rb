module SoberSwag
  module Reporting
    module Output
      ##
      # Output booleans.
      class Bool < Base
        def call(input)
          input
        end

        def serialize_report(input)
          result = call(input)

          return Report::Value.new(['was not a boolean']) unless [true, false].include?(result)

          result
        end

        def swagger_schema
          [{ type: 'boolean' }, {}]
        end
      end
    end
  end
end
