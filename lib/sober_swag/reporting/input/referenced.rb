module SoberSwag
  module Reporting
    module Input
      ##
      # An input that should be "referenced" in the final schema.
      class Referenced < Base
        def initialize(value, reference)
          @value = value
          @reference = reference
        end

        ##
        # @return [Interface] the actual input
        attr_reader :value
        ##
        # @return [String] key in the components hash
        attr_reader :reference

        def call(input)
          @value.call(input)
        end

        def swagger_schema
          [
            { "$ref": ref_path },
            { reference => proc { value.swagger_schema } }
          ]
        end

        private

        def ref_path
          "#/components/schemas/#{reference}"
        end
      end
    end
  end
end
