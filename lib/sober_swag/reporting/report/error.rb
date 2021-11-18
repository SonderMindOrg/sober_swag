module SoberSwag
  module Reporting
    module Report
      ##
      # Exception thrown when used with {Reporting::Input::Base#call!}
      class Error < StandardError
        def initialize(report)
          @report = report
        end

        attr_reader :report
      end

    end
  end
end
