module SoberSwag
  module Reporting
    module Input
      ##
      # Input for a single text value.
      class Text < Base
        def call(value)
          return value if value.is_a?(String)

          Report::Value.new(['was not a string'])
        end

        ##
        # Get a new input value which requires a regexp.
        #
        # @paran regexp [Regexp] regular expression to match on
        # @return [Pattern] pattern-based input.
        def with_pattern(regexp)
          Pattern.new(self, regexp)
        end

        include Comparable

        def eql?(other)
          other.class == self.class
        end

        def <=>(other)
          eql?(other) ? 0 : 1
        end

        def hash
          [self.class.hash, 1].hash
        end

        def swagger_schema
          [{ type: 'string' }, {}]
        end
      end
    end
  end
end
