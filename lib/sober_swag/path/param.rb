module SoberSwag
  class Path
    ##
    # Parse a parameter
    class Param
      def initialize(name, type)
        @name = name
        @type = type
      end

      def param?
        true
      end

      def param_key
        @name
      end

      def param_type
        @type
      end

      def match(param)
        if (m = @type.try(param)).success?
          [:match, m]
        else
          [:fail]
        end
      end

    end
  end
end
