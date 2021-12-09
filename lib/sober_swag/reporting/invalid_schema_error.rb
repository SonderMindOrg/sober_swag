module SoberSwag
  module Reporting
    ##
    # Thrown we c
    class InvalidSchemaError < StandardError
      def initialize(input)
        @input = input

        super("Could not generate schema for #{input}")
      end

      attr_reader :input

      class InvalidForPathError < InvalidSchemaError; end
      class InvalidForQueryError < InvalidSchemaError; end
    end
  end
end
