module SoberSwag
  module Reporting
    module Output
      ##
      # Serialize a list of some other output type.
      # Passes views down.
      class List < Base
        def initialize(element_output)
          @element_output = element_output
        end

        attr_reader :element_output

        def view(view)
          List.new(element_output.view(view))
        end

        def views
          element_output.views
        end

        def call(input)
          input.map { |i| element_output.call(i) }
        end

        def swagger_schema
          schema, found = element_output.swagger_schema
          [
            {
              type: 'array',
              items: schema
            },
            found
          ]
        end

        def serialize_report(input)
          return Report::Value.new(['could not be made an array']) unless input.respond_to?(:map)

          errs = {}
          mapped = input.map.with_index do |item, idx|
            element.serialize_report(item).tap { |e| errs[idx] = e if e.is_a?(Report::Base) }
          end

          if errs.any?
            Report::List.new(errs)
          else
            mapped
          end
        end
      end
    end
  end
end
