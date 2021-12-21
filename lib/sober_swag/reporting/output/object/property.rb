module SoberSwag
  module Reporting
    module Output
      class Object
        ##
        # Definitions for a specific property of an object.
        class Property
          def initialize(output, description: nil)
            @output = output
            @description = description
          end
          ##
          # @return [Interface]
          attr_reader :output

          ##
          # @return [String,nil]
          attr_reader :description

          def call(item, view: :base)
            output.call(item, view: view)
          end

          def property_schema
            direct, refined = output.swagger_schema

            if description
              [add_description(direct), refined]
            else
              [direct, refined]
            end
          end

          def add_description(dir)
            if dir.key?(:$ref)
              { allOf: [dir] }
            else
              dir
            end.merge(description: description)
          end
        end
      end
    end
  end
end
