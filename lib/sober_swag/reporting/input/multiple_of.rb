module SoberSwag
  module Reporting
    module Input
      ##
      # Adds the multipleOf constraint to input types.
      # Will use the '%' operator to calculate this, which may behave oddly for floats.
      class MultipleOf < Base
        def initialize(input, mult)
          @input = input
          @mult = mult
        end

        ##
        # @return [Interface]
        attr_reader :input

        ##
        # @return [Numeric]
        attr_reader :mult

        def call(value)
          parsed = input.call(value)

          return parsed if parsed.is_a?(Report::Base)
          return Report::Value.new(["was not a multiple of #{mult}"]) unless (parsed % mult).zero?

          parsed
        end

        def swagger_schema
          modify_schema(input, { multipleOf: mult })
        end
      end
    end
  end
end
