module SoberSwag
  module Path
    ##
    # One literal text fragment, basically
    class Literal < Node
      ##
      # Make a new text node
      # @param text [String]
      def initialize(text)
        @text = text
      end

      attr_reader :text

      ##
      # We can make a jump table out of this node!
      def jumpable?
        true
      end

      ##
      # This doesn't read a parameter type.
      def param?
        false
      end

    end
  end
end
