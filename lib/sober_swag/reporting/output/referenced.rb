module SoberSwag
  module Reporting
    module Output
      ##
      # Referenced: An input that will be referred to via reference in the
      # final schema.
      class Referenced < Base
        def initialize(output, reference)
          @output = output
          @reference = reference
        end

        ##
        # @return [Interface] the actual output type to use
        attr_reader :output

        ##
        # @return [String] key in the components hash
        attr_reader :reference

        def call(input)
          output.call(input)
        end

        def ref_path
          "#/components/schemas/#{reference}"
        end

        def swagger_schema
          [
            { "$ref": ref_path },
            { reference => proc { output.swagger_schema } }
          ]
        end
      end
    end
  end
end
