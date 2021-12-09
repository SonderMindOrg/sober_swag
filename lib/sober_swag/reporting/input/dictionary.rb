module SoberSwag
  module Reporting
    module Input
      ##
      # Dictionary types: string keys, something else as a value.
      class Dictionary < Base
        def self.of(input_type)
          new(input_type)
        end

        def initialize(value_input)
          @value_input = value_input
        end

        attr_reader :value_input

        def call(value)
          return Report::Base.new(['was not an object']) unless value.is_a?(Hash)

          bad, good = value.map { |k, v|
            [k, value_input.call(v)]
          }.compact.partition { |(_, v)| v.is_a?(Report::Base) }

          return Report::Object.new(bad.to_h) if bad.any?

          good.to_h
        end

        def swagger_schema
          schema, found = value_input.swagger_schema

          [{ type: :object, additionalProperties: schema }, found]
        end
      end
    end
  end
end
