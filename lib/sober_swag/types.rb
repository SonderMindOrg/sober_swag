module SoberSwag
  ##
  # Container for types.
  # You can use constants like SoberSwag::Types::Integer and things as a result of this module existing.
  class Types
    include ::Dry::Types()

    ##
    # An array that will be parsed from comma-separated values in a string, if given a string.
    CommaArray = Array.meta(format: :form, explode: false).constructor do |val|
      if val.is_a?(::String)
        val.split(',').map(&:strip)
      else
        val
      end
    end
  end
end
