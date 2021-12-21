module SoberSwag
  module Reporting
    module Output
      ##
      # Output a dictionary of key-value pairs.
      class Dictionary < Base
        def self.of(valout)
          new(valout)
        end

        def initialize(value_output)
          @value_output = value_output
        end

        attr_reader :value_output

        def call(item)
          item.transform_values { |v| value_output.call(v) }
        end

        def serialize_report(item)
          return Report::Base.new(['was not a dict']) unless item.is_a?(Hash)

          bad, good = item.map { |k, v|
            [k, value_output.serialize_report(v)]
          }.compact.partition { |(_, v)| v.is_a?(Report::Base) }

          return Report::Object.new(bad.to_h) if bad.any?

          good.to_h
        end

        def swagger_schema
          schema, found = value_output.swagger_schema
          [
            {
              type: :object,
              additionalProperties: schema
            },
            found
          ]
        end
      end
    end
  end
end
