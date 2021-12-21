module SoberSwag
  module Reporting
    module Input
      ##
      # Specify that a value must be included in a list of possible values.
      class Enum < Base
        def initialize(input, values)
          @input = input
          @values = values
        end

        ##
        # @return [Interface] base type
        attr_reader :input

        ##
        # @return [Array<String>] acceptable types
        attr_reader :values

        def call(value)
          inner = input.call(value)

          return inner if inner.is_a?(Report::Base)

          return Report::Value.new(['was not an acceptable enum member']) unless values.include?(inner)

          inner
        end

        def swagger_schema
          schema, found = input.swagger_schema

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
