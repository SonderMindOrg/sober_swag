module SoberSwag
  module Reporting
    module Input
      module Converting
        ##
        # Convert via a date.
        DateTime =
          SoberSwag::Reporting::Input::Text
          .new
          .mapped { |str|
            begin
              ::DateTime.rfc3339(str)
            rescue ArgumentError
              Report::Value.new(['was not an RFC 3339 date-time string'])
            end
          }.or(
            SoberSwag::Reporting::Input::Text
              .new
              .mapped do |str|
              ::DateTime.iso8601(str)
            rescue ArgumentError
              Report::Value.new(['was not an ISO8601 date-time string'])
            end
          ).format('date-time')
      end
    end
  end
end
