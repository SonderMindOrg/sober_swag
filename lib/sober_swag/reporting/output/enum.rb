module SoberSwag
  module Reporting
    module Output
      ##
      # Models outputting an enum.
      class Enum < Base
        def initialize(output, values)
          @output = output
          @values = values
        end

        ##
        # @return [Interface]
        attr_reader :output

        ##
        # @return [Array]
        attr_reader :values

        def call(value)
          output.call(value)
        end

        def serialize_report(value)
          rep = output.serialize_report(value)

          return rep if rep.is_a?(Report::Base)

          return Report::Value.new(['was not an acceptable enum member']) unless values.include?(rep)

          rep
        end

        def swagger_schema
          schema, found = output.swagger_schema
          merged =
            if schema.key?(:$ref)
              { allOf: [schema] }
            else
              schema
            end.merge(enum: values)
          [merged, found]
        end
      end
    end
  end
end
