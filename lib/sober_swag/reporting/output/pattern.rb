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
          base = output.serialize_report(value)

          return base if base.is_a?(Report::Error)

          if pattern.match?(base)
            base
          else
            Report::Value.new(['did not match pattern'])
          end
        end

        def swagger_schema
          schema, defs = output.swagger_schema

          merged =
            if schema.key?(:$ref)
              { oneOf: [schema] }
            else
              schema
            end.merge(pattern: pattern.to_s.gsub('?-mix:', ''))
          [merged, defs]
        end
      end
    end
  end
end
