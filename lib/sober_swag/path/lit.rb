module SoberSwag
  class Path
    class Lit
      ##
      # Parse a literal path fragment
      def initialize(lit)
        @lit = lit
      end

      attr_reader :lit

      def param?
        false
      end

      def param_type
        nil
      end

      def param_key
        nil
      end

      ##
      # Constant to avoid a bunch of array allocation
      MATCH_SUCC = [:match, nil].freeze
      ##
      # Constant to avoid a bunch of array allocation
      MATHC_FAIL = [:fail].freeze

      def match(param)
        if param == lit
          MATCH_SUCC
        else
          MATCH_FAIL
        end
      end

    end
  end
end
