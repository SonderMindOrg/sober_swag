module SoberSwag
  module Reporting
    module Input
      module Converting
        ##
        # Parse a decimal.
        Decimal =
          (SoberSwag::Reporting::Input::Number.new.mapped(&:to_d).format(:decimal) |
          SoberSwag::Reporting::Input::Text
          .new
          .format('decimal')
          .mapped do |v|
            BigDecimal(v)
          rescue ArgumentError
            Report::Value.new('was not a decimal')
          end).described(<<~MARKDOWN).referenced('SoberSwag.Converting.Decimal')
            Decimal formatted input.
            Will either convert a JSON number to a decimal, or accept a string representation.
            The string representation allows for greater precision.
          MARKDOWN
      end
    end
  end
end
