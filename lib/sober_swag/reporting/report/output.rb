module SoberSwag
  module Reporting
    module Report
      ##
      # Output suitable to serialize an instance of {SoberSwag::Reporting::Report::Base} to
      # a nice key-value thing.
      Output = SoberSwag::Reporting::Output::Dictionary.of(
        SoberSwag::Reporting::Output::List.new(
          SoberSwag::Reporting::Output.text
        )
      ).via_map(&:path_hash)
    end
  end
end
