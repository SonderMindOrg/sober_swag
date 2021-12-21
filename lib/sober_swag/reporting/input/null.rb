module SoberSwag
  module Reporting
    module Input
      ##
      # Null input values.
      # Validates that the input is null.
      class Null < Base
        def call(value)
          return nil if value.nil?

          Report::Value.new(['was not nil'])
        end

        def hash
          [self.class.hash, 1].hash
        end

        def eql?(other)
          other.class == self.class
        end

        def <=>(other)
          eql?(other) ? 0 : nil
        end

        include Comparable

        def swagger_schema
          [{ type: 'null' }, {}]
        end
      end
    end
  end
end
