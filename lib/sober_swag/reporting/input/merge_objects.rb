module SoberSwag
  module Reporting
    module Input
      ##
      # Merge two object types together, in an allof stype relationship
      class MergeObjects < Base
        def initialize(parent, child)
          @parent = parent
          @child = child
        end

        ##
        # @return [Interface] parent type
        attr_reader :parent

        ##
        # @return [Interface] child type
        attr_reader :child

        def call(value)
          parent_attrs = parent.call(value)

          return parent_attrs if parent_attrs.is_a?(Report::Value)

          # otherwise, object type, so we want to get a full error report

          child_attrs = child.call(value)

          return child_attrs if child_attrs.is_a?(Report::Value)

          merge_results(parent_attrs, child_attrs)
        end

        private

        def merge_results(par, chi) # rubocop:disable Metrics/MethodLength
          if par.is_a?(Report::Base)
            if chi.is_a?(Report::Base)
              Report::MergedObject.new(par, chi)
            else
              par
            end
          elsif chi.is_a?(Report::Base)
            chi
          else
            par.to_h.merge(chi.to_h)
          end
        end
      end
    end
  end
end
