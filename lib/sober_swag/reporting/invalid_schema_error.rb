module SoberSwag
  module Reporting
    ##
    # Thrown we cannot generate a swagger schema for some reason.
    #
    # This typically only occurs if you use types that are too complicated.
    # For example, an object type cannot be used as part of the path params.
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
