module SoberSwag
  module Reporting
    module Input
      class Object
        ##
        # Describe a single property key in an object.
        class Property
          def initialize(value, required:, description: '')
            @value = value
            @required = required
            @description = description
          end

          ##
          # @return [SoberSwag::Reporting::Input::Interface] value type
          attr_reader :value

          def required?
            @required
          end

          ##
          # @return [String, nil] description
          attr_reader :description

          def property_schema
            direct, refined = value.swagger_schema

            if description
              [add_description(direct), refined]
            else
              [direct, refined]
            end
          end

          private

          def add_description(dir)
            t =
              if dir.key?(:$ref)
                # workaround: we have to do this if we want to allow
                # descriptions in reference types
                { allOf: [dir] }
              else
                dir
              end
            t.merge(description: description)
          end
        end
      end
    end
  end
end
