module SoberSwag
  module Reporting
    module Input
      ##
      # Apply a mapping function over an input.
      class Mapped < Base
        ##
        # @param mapper [#call] the mapping function
        # @param input [Base] the base input
        def initialize(input, mapper)
          @mapper = mapper
          @input = input
        end

        ##
        # @return [#call] mapping function
        attr_reader :mapper
        ##
        # @return [Base] base input
        attr_reader :input

        def call(value)
          val = input.call(value)

          return val if val.is_a?(Report::Base)

          mapper.call(val)
        end

        def swagger_schema
          input.swagger_schema
        end
      end
    end
  end
end
