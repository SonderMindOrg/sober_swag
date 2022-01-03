module SoberSwag
  module Reporting
    module Input
      ##
      # Specify that an item must be within a given range in ruby.
      # This gets translated to `minimum` and `maximum` keys in swagger.
      #
      # This works with endless ranges (Ruby 2.6+) and beginless ranges (Ruby 2.7+)
      class InRange < Base
        def initialize(input, range)
          @input = input
          @range = range
        end

        ##
        # @return [Interface]
        attr_reader :input

        ##
        # @return [Range]
        attr_reader :range

        ##
        # @return [Range]
        def call(value)
          res = input.call(value)

          return res if res.is_a?(Report::Base)
          return Report::Value.new(['was not in minimum/maximum range']) unless range.member?(res)

          res
        end

        def swagger_schema
          schema, found = input.swagger_schema

          merged =
            if schema.key?(:$ref)
              { allOf: [schema] }
            else
              schema
            end.merge(maximum_portion).merge(minimum_portion)

          [merged, found]
        end

        def maximum_portion
          return {} unless range.end

          { maximum: range.end, exclusiveMaximum: range.exclude_end? }
        end

        def minimum_portion
          return {} unless range.begin

          { minimum: range.begin, exclusiveMinimum: false }
        end
      end
    end
  end
end
