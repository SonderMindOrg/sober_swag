module SoberSwag
  module Reporting
    module Report
      ##
      # Report on problems with a merged object.
      class MergedObject < Base
        def initialize(parent, child)
          @parent = parent
          @child = child
        end

        attr_reader :parent, :child

        def each_error
          return enum_for(:each_error) unless block_given?

          # rubocop:disable Style/ExplicitBlockArgument
          parent.each_error { |k, v| yield k, v }
          child.each_error { |k, v| yield k, v }
          # rubocop:enable Style/ExplicitBlockArgument
        end
      end
    end
  end
end
