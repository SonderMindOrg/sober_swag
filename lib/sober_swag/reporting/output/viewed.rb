module SoberSwag
  module Reporting
    module Output
      ##
      # Augment output objects with views.
      class Viewed < Base
        def initialize(views)
          @view_map = views

          raise ArgumentError, 'views must have a base key' unless views.key?(:base)
        end

        attr_reader :view_map

        def call(input)
          view(:base).call(input)
        end

        def serialize_report(input)
          view(:base).call(input)
        end

        ##
        # Get a view with a particular key.
        def view(view)
          view_map.fetch(view)
        end

        def views
          view_map.keys.to_set
        end

        def with_view(name, val)
          Viewed.new(views.merge(name => val))
        end

        def swagger_schema
          found = {}
          possibles = view_map.values.flat_map do |v|
            view_item, view_found = v.swagger_schema
            found.merge!(view_found)
            view_item[:oneOf] || [view_item]
          end
          [{ oneOf: possibles }, found]
        end
      end
    end
  end
end
