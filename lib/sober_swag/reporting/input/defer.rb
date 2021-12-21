module SoberSwag
  module Reporting
    module Input
      ##
      # Resolve circular references by deferring the loading of an input.
      class Defer < Base
        def initialize(other_lazy)
          @other_lazy = other_lazy
        end

        attr_reader :other_lazy

        def other
          return @other if defined?(@other)

          @other = other_lazy.call
        end

        def call(input)
          other.call(input)
        end

        def swagger_schema
          other.swagger_schema
        end
      end
    end
  end
end
