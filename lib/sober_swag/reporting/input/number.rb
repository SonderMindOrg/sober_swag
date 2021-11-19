module SoberSwag
  module Reporting
    module Input
      ##
      # Parse some kind of number.
      class Number < Base
        def call(input)
          return Report::Value.new(['is not a number']) unless input.is_a?(Numeric)

          input
        end

        def swagger_schema
          [{ type: 'number' }, {}]
        end
      end
    end
  end
end
