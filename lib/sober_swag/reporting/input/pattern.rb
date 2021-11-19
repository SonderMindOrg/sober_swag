module SoberSwag
  module Reporting
    module Input
      ##
      # Input values that validate against a pattern
      class Pattern < Base
        def initialize(input, pattern)
          @input = input
          @pattern = pattern
        end

        ##
        # @return [#call] input type
        attr_reader :input

        ##
        # @return [#matches] regexp matcher
        attr_reader :pattern

        def call(value)
          val = input.call(value)

          return val if val.is_a?(Report::Base)

          if pattern.match?(value)
            value
          else
            Report::Value.new(["did not match pattern #{pattern}"])
          end
        end

        def swagger_schema
          single, found = input.swagger_schema

          [add_schema_key(single, { pattern: formatted_pattern }), found]
        end

        ##
        # Try to format a pattern so it'll work nicely with JS.
        def formatted_pattern
          pattern.to_s.gsub('?-mix:', '')
        end
      end
    end
  end
end
