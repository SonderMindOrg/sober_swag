module SoberSwag
  module Reporting
    module Output
      ##
      # Output numbers of some variety.
      class Number < Base
        def call(input)
          input
        end

        def serialize_report(input)
          result = call(input)

          return Report::Value.new(['was not a number']) unless result.is_a?(Numeric)

          result
        end

        def swagger_schema
          [{ type: 'number' }, {}]
        end
      end
    end
  end
end
