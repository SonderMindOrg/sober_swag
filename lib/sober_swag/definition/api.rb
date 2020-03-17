module SoberSwag
  module Definition
    ##
    # Definition for an entire api
    class Api
      def initialize
        @paths = Hash.new { |h, k| h[k] = Path.new }
      end

      attr_reader :paths

      def path(path)
        @paths[path]
      end
    end
  end
end
