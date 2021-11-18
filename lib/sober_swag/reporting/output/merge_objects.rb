module SoberSwag
  module Reporting
    module Output
      ##
      # Represent an allOf, basically.
      class MergeObjects < Base
        def initialize(parent, child)
          @parent = parent
          @child = child
        end

        ##
        # @return [Interface] first object to merge
        attr_reader :parent
        ##
        # @return [Interface] second object to merge
        attr_reader :child

        def call(input)
          parent.call(input).merge(child.call(input))
        end

        ##
        # Child views.
        def views
          child.views
        end

        ##
        # Passes on view to the child object.
        def view(view)
          MergeObjects.new(parent, child.view(view))
        end

        # TODO: serialize report

        def swagger_schema
          found = {}
          mapped = [parent, child].flat_map do |i|
            schema, item_found = i.swagger_schema
            found.merge!(item_found)
            if schema.key?(:allOf)
              schema[:allOf]
            else
              [schema]
            end
          end
          [{ allOf: mapped }, found]
        end
      end
    end
  end
end
