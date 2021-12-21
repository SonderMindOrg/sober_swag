module SoberSwag
  module Reporting
    module Input
      module Converting
        ##
        # Try to convert a boolean-like value to an actual boolean.
        Bool = # rubocop:disable Naming/ConstantName
          (SoberSwag::Reporting::Input::Bool.new |
           (
             SoberSwag::Reporting::Input::Text
              .new
              .enum(*(%w[y yes true t].flat_map { |x| [x, x.upcase] } + ['1'])) |
              SoberSwag::Reporting::Input::Number.new.enum(1)).mapped { |_| true } |
            (
              SoberSwag::Reporting::Input::Text
                .new
                .enum(*(%w[false no n f].flat_map { |x| [x, x.upcase] } + ['0'])) |
              SoberSwag::Reporting::Input::Number.new.enum(0)
            ).mapped { |_| false }
          )
      end
    end
  end
end
