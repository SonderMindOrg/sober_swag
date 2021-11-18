module SoberSwag
  module Reporting
    module Report
      ##
      # Models either one set of errors or another.
      # Will enumerate them in order with #each_error
      class Either < Base
        def initialize(lhs, rhs)
          @lhs = lhs
          @rhs = rhs
        end

        ##
        # @return [Base] left reports
        attr_reader :lhs
        ##
        # @return [Base] right reports
        attr_reader :rhs

        # rubocop:disable Style/ExplicitBlockArgument
        def each_error
          return enum_for(:each_error) unless block_given?

          lhs.each_error do |key, value|
            yield key, value
          end

          rhs.each_error do |key, value|
            yield key, value
          end
        end
        # rubocop:enable Style/ExplicitBlockArgument
      end
    end
  end
end
