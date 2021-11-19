module SoberSwag
  module Reporting
    module Input
      ##
      # Specify that something must match a particular format.
      # Note: said format is just a string.
      class Format < Base
        def initialize(input, format)
          @input = input
          @format = format
        end

        ##
        # @return [Interface]
        attr_reader :input

        ##
        # @return [String]
        attr_reader :format

        def call(object)
          input.call(object)
        end

        def swagger_schema
          schema, found = input.swagger_schema

          merged =
            if schema.key?(:$ref)
              { allOf: [schema] }
            else
              schema
            end.merge(format: format)
          [merged, found]
        end
      end
    end
  end
end
