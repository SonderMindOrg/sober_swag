module SoberSwag
  module Reporting
    module Output
      ##
      # Augment outputs with the ability to select views.
      # This models a 'oneOf' relationship, where the choice picked is controlled by the 'view' parameter.
      #
      # This is "optional choice," in the sense that you *must* provide a default `:base` key.
      # This key will be used in almost all cases.
      class Viewed < Base
        ##
        # @param views [Hash<Symbol,Interface>] a map of view key to view.
        #   Note: this map *must* include the base view.
        def initialize(views)
          @view_map = views

          raise ArgumentError, 'views must have a base key' unless views.key?(:base)
        end

        attr_reader :view_map

        ##
        # Serialize out an object.
        # If the view key is not provided, use the base view.
        #
        # @param input [Object] object to serialize
        # @param view [Symbol] which view to use.
        #   If view is not valid, an exception will be thrown
        # @raise [KeyError] if view is not valid
        # @return [Object,String,Array,Numeric] JSON-serializable object.
        #   Suitable for use with #to_json.
        def call(input, view: :base)
          view(view).call(input)
        end

        def serialize_report(input)
          view(:base).call(input)
        end

        ##
        # Get a view with a particular key.
        def view(view)
          view_map.fetch(view)
        end

        ##
        # @return [Set<Symbol>] all of the views applicable.
        def views
          view_map.keys.to_set
        end

        ##
        # Add (or override) the possible views.
        #
        # @return [Viewed] a new view map, with one more view.
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
