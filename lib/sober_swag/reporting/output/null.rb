module SoberSwag
  module Reporting
    module Output
      ##
      # Output JSON nulls.
      class Null < Base
        def call(input)
          input
        end

        def serialize_report(input)
          result = call(input)

          return Report::Value.new(['was not null']) unless result.nil?

          result
        end

        def swagger_schema
          [{ type: 'null' }, {}]
        end
      end
    end
  end
end
