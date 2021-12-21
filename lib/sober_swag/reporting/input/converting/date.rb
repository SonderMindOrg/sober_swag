module SoberSwag
  module Reporting
    module Input
      module Converting
        ##
        # Convert via a date.
        #
        # Note: unlike the swagger spec, we first try to convert
        # rfc8601, then try rfc3339.
        Date = (
          SoberSwag::Reporting::Input::Text
               .new
               .mapped { |str|
            begin
              ::Date.rfc3339(str)
            rescue ArgumentError
              Report::Value.new(['was not an RFC 3339 date string'])
            end
          } |
          SoberSwag::Reporting::Input::Text
            .new
            .mapped do |str|
            ::Date.iso8601(str)
          rescue ArgumentError
            Report::Value.new(['was not an ISO8601 date string'])
          end).format('date')
      end
    end
  end
end
