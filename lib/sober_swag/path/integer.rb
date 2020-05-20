module SoberSwag
  module Path
    class Integer < Node

      def initialize; end;

      def jumpable?
        true
      end

      def param?
        true
      end

      def param_type
        SoberSwag::Types::Paramter::Integer
      end

    end
  end
end
