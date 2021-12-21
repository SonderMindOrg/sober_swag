module SoberSwag
  module Reporting
    module Input
      ##
      # Parses either one input, or another.
      # Left-biased.
      class Either < Base
        ##
        # @param lhs [Base] an input we will try first
        # @param rhs [Base] an input we will try second
        def initialize(lhs, rhs)
          @lhs = lhs
          @rhs = rhs
        end

        ##
        # @return [Base] parser for LHS
        attr_reader :lhs
        ##
        # @return [Base] parser for RHS
        attr_reader :rhs

        def call(value)
          maybe_lhs = lhs.call(value)

          return maybe_lhs unless maybe_lhs.is_a?(Report::Base)

          maybe_rhs = rhs.call(value)

          return maybe_rhs unless maybe_rhs.is_a?(Report::Base)

          Report::Either.new(maybe_lhs, maybe_rhs)
        end

        def swagger_schema
          lhs_val, lhs_set = lhs.swagger_schema
          rhs_val, rhs_set = rhs.swagger_schema

          val = { oneOf: defs_for(lhs_val) + defs_for(rhs_val) }
          [val, lhs_set.merge(rhs_set)]
        end

        private

        def defs_for(schema)
          schema[:oneOf] || [schema]
        end
      end
    end
  end
end
