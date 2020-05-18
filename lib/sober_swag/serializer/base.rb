module SoberSwag
  module Serializer
    class Base

      ##
      # Return a new serializer that is an *array* of elements of this serializer.
      def array
        SoberSwag::Serializer::Array.new(self)
      end

      ##
      # Returns a serializer that will pass `nil` values on unscathed
      def optional
        SoberSwag::Serializer::Optional.new(self)
      end

      ##
      # If I am a serializer for type 'a', and you give me a way to turn 'a's into 'b's,
      # I can give you a serializer for type 'b' by running the funciton you gave.
      # For example, if I am a serializer for {String}, and you know how to turn
      # an {Int} into a {String}, I can now serialize {Int}s (by turning them into a string).
      #
      # Note that the *declared* type of this is *not* changed: from a user's perspective,
      # they see a "string"
      def via_map(&block)
        SoberSwag::Serializer::Mapped.new(self, block)
      end

    end
  end
end
