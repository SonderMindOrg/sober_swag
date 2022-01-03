module SoberSwag
  module Reporting
    module Input
      ##
      # Input object values
      class Object < Base
        autoload :Property, 'sober_swag/reporting/input/object/property'
        ##
        # @param fields [Hash<Symbol, Property>]
        def initialize(fields)
          @fields = fields
        end

        ##
        # @return [Hash<String,#call>]
        attr_reader :fields

        def call(value)
          return Report::Value.new(['was a not a JSON object']) unless value.is_a?(Hash)

          bad, good = fields.map { |k, prop|
            extract_value(k, prop, value)
          }.compact.partition { |(_, v)| v.is_a?(Report::Base) }

          return Report::Object.new(bad.to_h) if bad.any?

          good.to_h
        end

        def swagger_schema
          fields, found = field_schemas

          obj = {
            type: 'object',
            properties: fields
          }.merge(required_portion)

          [obj, found]
        end

        def swagger_query_schema
          swagger_parameter_schema.map do |param|
            param.merge({ in: :query, style: :deepObject, explode: true })
          end
        end

        def swagger_path_schema
          swagger_parameter_schema.map do |param|
            param.merge({ in: :path })
          end
        end

        private

        def swagger_parameter_schema
          fields.map do |name, field|
            key_schema, = field.property_schema
            base = {
              name: name,
              schema: key_schema,
              required: field.required?
            }
            field.description ? base.merge(description: field.description) : base
          end
        end

        def field_schemas
          fields.reduce([{}, {}]) do |(field_schemas, found), (k, v)|
            key_schema, key_found = v.property_schema
            [
              field_schemas.merge(k => key_schema),
              found.merge(key_found)
            ]
          end
        end

        ##
        # Either the list of required keys, or something stating "provide at least one key."
        # This is needed because you can't have an empty list of keys.
        def required_portion
          required_fields = fields.map { |k, v| k if v.required? }.compact

          if required_fields.empty?
            {}
          else
            { required: required_fields }
          end
        end

        def extract_value(key, property, input)
          if input.key?(key)
            [key, property.value.call(input[key])]
          elsif property.required?
            [key, Report::Value.new(['is required'])]
          end
        end
      end
    end
  end
end
