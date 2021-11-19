module SoberSwag
  module Reporting
    module Input
      ##
      # Node for things with descriptions.
      # This describes the *type*, not the *object key*.
      class Described < Base
        def initialize(input, description)
          @input = input
          @description = description
        end

        ##
        # @return [Interface] base input
        attr_reader :input

        ##
        # @return [String] description of input
        attr_reader :description

        def call(value)
          input.call(value)
        end

        def swagger_schema
          val, other = input.swagger_schema
          merged =
            if val.key?(:$ref)
              { allOf: [val] }
            else
              val
            end.merge(description: description)
          [merged, other]
        end
      end
    end
  end
end
