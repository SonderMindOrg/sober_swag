module SoberSwag
  module Reporting
    module Output
      ##
      # Add a description onto an object.
      class Described < Base
        def initialize(output, description)
          @output = output
          @description = description
        end

        ##
        # @return [Interface] output to describe
        attr_reader :output

        ##
        # @return [String] description of output
        attr_reader :description

        def call(value)
          output.call(value)
        end

        def serialize_report(value)
          output.serialize_report(value)
        end

        def swagger_schema
          schema, found = output.swagger_schema

          merged =
            if schema.key?(:$ref)
              { allOf: [schema] }
            else
              schema
            end.merge(description: description)
          [merged, found]
        end
      end
    end
  end
end
