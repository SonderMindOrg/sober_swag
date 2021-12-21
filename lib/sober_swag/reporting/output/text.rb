module SoberSwag
  module Reporting
    module Output
      ##
      # Output raw text.
      class Text < Base
        def call(input)
          input
        end

        def serialize_report(input)
          result = call(input)

          return Report::Value.new(['was not a string']) unless result.is_a?(String)

          result
        end

        def swagger_schema
          [{ type: 'string' }, {}]
        end
      end
    end
  end
end
