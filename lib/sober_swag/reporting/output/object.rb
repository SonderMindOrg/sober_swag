module SoberSwag
  module Reporting
    module Output
      ##
      # Serialize out a JSON object.
      class Object < Base
        autoload(:Property, 'sober_swag/reporting/output/object/property')

        ##
        # @param properties [Hash<Symbol,Property>] the properties to serialize
        def initialize(properties)
          @properties = properties
        end

        ##
        # @param properties [Hash<Symbol,Property>]
        attr_reader :properties

        def call(item)
          properties.each.with_object({}) do |(k, v), hash|
            hash[k] = v.output.call(item)
          end
        end

        def serialize_report(item)
          bad, good = properties.map { |k, prop|
            [k, prop.output.serialize_report(item)]
          }.partition { |(_, v)| v.is_a?(Report::Base) }

          return Report::Object.new(bad.to_h) if bad.any?

          good.to_h
        end

        def swagger_schema # rubocop:disable Metrics/MethodLength
          props, found = properties.each.with_object([{}, {}]) do |(k, v), (field, f)|
            prop_type, prop_found = v.property_schema
            field[k] = prop_type
            f.merge!(prop_found)
          end

          [
            {
              type: 'object',
              properties: props,
              required: properties.keys
            },
            found
          ]
        end
      end
    end
  end
end
