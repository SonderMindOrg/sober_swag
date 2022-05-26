module SoberSwag
  module Reporting
    module Report
      ##
      # Exception thrown when used with {Reporting::Input::Interface#call!}.
      class Error < StandardError
        def initialize(report)
          @report = report
        end

        def message
          "Reported errors: #{report.full_errors.join(',')}"
        end

        attr_reader :report
      end
    end
  end
end
