module SoberSwag
  module Reporting
    module Output
      ##
      # Represents object that are marged with `allOf` in swagger.
      #
      # These *have* to be objects, due to how `allOf` works.
      # This expresses a subtyping relationship.
      #
      # Note: non-careful use of this can generate impossible objects,
      # IE, objects where a certain field has to be *both* a string and an integer or something.
      # Subtyping is dangerous and should be used with care!
      #
      # This class is used in the implementation of {SoberSwag::Reporting::Output::Struct},
      # in order to model the inheritence relationship structs have.
      class MergeObjects < Base
        ##
        # @param parent [Interface] parent interface to use.
        #   Should certainly be some sort of object, or a reference to it.
        # @param child [Interface] child interface to use.
        #   Should certainly be some sort of object, or a reference to it.
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

        ##
        # Serialize with the parent first, then merge in the child.
        # This *does* mean that parent keys override child keys.
        #
        # If `parent` or `child` does not serialize some sort of object, this will result in an error.
        def call(input)
          parent.call(input).merge(child.call(input))
        end

        ##
        # Child views.
        def views
          child.views
        end

        ##
        # Passes on view to the *child object*.
        def view(view)
          MergeObjects.new(parent, child.view(view))
        end

        def serialize_report(value)
          parent_attrs = parent.serialize_report(value)

          return parent_attrs if parent_attrs.is_a?(Report::Value)

          child_attrs = child.serialize_report(value)

          return child_attrs if child_attrs.is_a?(Report::Value)

          merge_results(parent_attrs, child_attrs)
        end

        ##
        # Swagger schema.
        #
        # This will collapse 'allOf' keys, so a chain of parent methods will be
        def swagger_schema # rubocop:disable Metrics/MethodLength
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

        private

        def merge_results(par, chi)
          return Report::MergedObject.new(par, chi) if [par, chi].all? { |c| c.is_a?(Report::Base) }
          return par if par.is_a?(Report::Base)
          return chi if chi.is_a?(Report::Base)

          par.to_h.merge(chi.to_h)
        end
      end
    end
  end
end
