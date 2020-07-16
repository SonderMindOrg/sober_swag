module SoberSwag
  module Serializer
    ##
    # Base interface class that all other serializers are subclasses of.
    # This also defines methods as stubs, which is sort of bad ruby style, but makes documentation
    # easier to generate.
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
      # Is this type lazily defined?
      #
      # Used for mutual recursion.
      def lazy_type?
        false
      end

      ##
      # The lazy version of this type, for mutual recursion.
      def lazy_type
        type
      end

      ##
      # Finalize a lazy type.
      #
      # Should be idempotent: call it once, and it does nothing on subsequent calls (but returns the type).
      def finalize_lazy_type!
        type
      end

      ##
      # Serialize an object.
      def serialize(_object, _options = {})
        raise ArgumentError, 'not implemented!'
      end

      ##
      # Get the type that we serialize to.
      def type
        raise ArgumentError, 'not implemented!'
      end

      ##
      # Add metadata onto the *type* of a serializer.
      def meta(hash)
        SoberSwag::Serializer::Meta.new(self, hash)
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

      ##
      # Serializer lets you get a serializer from things that might be classes
      # because of the blueprint naming hack.
      def serializer
        self
      end

      ##
      # Get the type name of this to be used externally, or set it if an argument is provided
      def identifier(arg = nil)
        @identifier = arg if arg
        @identifier
      end
    end
  end
end
