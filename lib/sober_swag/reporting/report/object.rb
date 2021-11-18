module SoberSwag
  module Reporting
    module Report
      ##
      # Report on problems with an object.
      class Object < Base
        ##
        # @param problems [Hash<Symbol, Report::Base>] the problems with each value.
        def initialize(problems)
          @problems = problems
        end

        ##
        # @return [Hash] the hash being reported on
        attr_reader :problems

        def each_error
          return enum_for(:each_error) unless block_given?

          problems.each do |k, v|
            v.each_error do |nested, err|
              yield [".#{k}", nested].reject(&:nil?).join(''), err
            end
          end
        end
      end
    end
  end
end
