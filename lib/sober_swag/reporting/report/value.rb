module SoberSwag
  module Reporting
    module Report
      ##
      # Report for a single value.
      # Basically a wrapper around an array of strings.
      class Value < Base
        ##
        # @param problems [Array<String>] problems with it
        def initialize(problems)
          raise ArgumentError, "#{problems} was not an enum" unless problems.respond_to?(:each)

          @problems = problems
        end

        ##
        # @return [Array<String>] the problems the value had
        attr_reader :problems

        def each_error
          return enum_for(:each_error) unless block_given?

          problems.each do |problem|
            yield nil, problem
          end
        end
      end
    end
  end
end
