module SoberSwag
  module Reporting
    module Output
      ##
      # Specify that an output will be within a certain range.
      # This gets translated to `minimum` and `maximum` keys in swagger.
      class InRange < Base
        def initialize(output, range)
          @output = output
          @range = range
        end

        ##
        # @return [Interface]
        attr_reader :output

        ##
        # @return [Range]
        attr_reader :range

        def call(value)
          output.call(value)
        end

        def serialize_report(value)
          rep = output.serialize_report(value)

          return rep if rep.is_a?(Report::Base)

          return Report::Value.new(['was not in minimum/maximum range']) unless range.member?(rep)

          rep
        end

        def swagger_schema
          schema, found = output.swagger_schema

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

          res = { maximum: range.end }
          res[:exclusiveMaximum] = true if range.exclude_end?
          res
        end

        def minimum_portion
          return {} unless range.begin

          { minimum: range.begin }
        end
      end
    end
  end
end
