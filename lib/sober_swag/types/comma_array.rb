module SoberSwag
  class Types
    ##
    # An array that will be parsed from comma-separated values in a string, if given a string.
    module CommaArray
      def self.of(other)
        SoberSwag::Types::Array.of(other).constructor { |val|
          if val.is_a?(::String)
            val.split(',').map(&:strip)
          else
            val
          end
        }.meta(style: :form, explode: false)
      end
    end
  end
end
