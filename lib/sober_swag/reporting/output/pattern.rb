module SoberSwag
  module Reporting
    module Output
      ##
      # Output with a particular pattern.
      class Pattern < Base
        def initialize(output, pattern)
          @output = output
          @pattern = pattern
        end

        ##
        # @return [Interface]
        attr_reader :output

        ##
        # @return [Regexp]
        attr_reader :pattern

        def call(input)
          output.call(input)
        end

        def serialize_report(value)
          based = output.serialize_report(value)

          return based if base.is_a?(Report::Error)

          if pattern.match?(base)
            base
          else
            Report::Value.new(['did not match pattern'])
          end
        end
      end
    end
  end
end
