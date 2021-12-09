module SoberSwag
  module Reporting
    module Input
      module Converting
        Integer =
          (SoberSwag::Reporting::Input.number.format('integer').mapped(&:to_i)) |
          (SoberSwag::Reporting::Input.text.format('integer').mapped do |v|
            Integer(v)
          rescue ArgumentError
            Report::Value.new('was not an integer string')
          end).described(<<~MARKDOWN).referenced('SoberSwag.Converting.Integer')
            Integer formatted input.

            With either convert a JSON number to an integer, or accept a string representation of an integer.
          MARKDOWN
      end
    end
  end
end
