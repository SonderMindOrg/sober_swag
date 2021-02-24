module SoberSwag
  module Serializer
    ##
    # Base class for everything that provides serialization functionality in SoberSwag.
    # SoberSwag serializers transform Ruby types into JSON types, with some associated *schema*.
    # This schema is then used in the generated OpenAPI V3 documentation.
    class Base
      ##
      # Return a new serializer that is an *array* of elements of this serializer.
      # This serializer will take in an array, and use `self` to serialize every element.
      #
      # @return [SoberSwag::Serializer::Array]
      def array
        SoberSwag::Serializer::Array.new(self)
      end

      ##
      # Returns a serializer that will pass `nil` values on unscathed.
      # That means that if you try to serialize `nil` with it, it will result in a JSON `null`.
      # @return [SoberSwag::Serializer::Optional]
      def optional
        SoberSwag::Serializer::Optional.new(self)
      end

      alias nilable optional

      ##
      # Add metadata onto the *type* of a serializer.
      # Note that this *returns a new serializer with metadata added* and does not perform mutation.
      # @param hash [Hash] the metadata to set.
      # @return [SoberSwag::Serializer::Meta] a serializer with metadata added
      def meta(hash)
        SoberSwag::Serializer::Meta.new(self, hash)
      end

      ##
      # Get a new serializer that will first run the given block before serializing an object.
      # For example, if you have a serializer for strings called `StringSerializer`,
      # and you want to serialize `Date` objects via encoding them to a standardized string format,
      # you can use:
      #
      # ```
      #   DateSerializer = StringSerializer.via_map do |date|
      #     date.strftime('%Y-%m-%d')
      #   end
      # ```
      #
      # @yieldparam [Object] the object before serialization
      # @yieldreturn [Object] a transformed object, that will
      #   be passed to {#serialize}
      # @return [SoberSwag::Serializer::Mapped] the new serializer
      def via_map(&block)
        SoberSwag::Serializer::Mapped.new(self, block)
      end

      ##
      # Is this type lazily defined?
      #
      # If we have two serializers that are *mutually recursive*, we need to do some "fun" magic to make that work.
      # This comes up in a case like:
      #
      # ```ruby
      #   SchoolClass = SoberSwag::OutputObject.define do
      #     field :name, primitive(:String)
      #     view :detail do
      #       field :students, -> { Student.view(:base) }
      #     end
      #   end
      #
      #   Student = SoberSwag::OutputObject.define do
      #     field :name, primitive(:String)
      #     view :detail do
      #       field :classes, -> { SchoolClass.view(:base) }
      #     end
      #   end
      # ```
      #
      # This would result in an infinite loop if we tried to define the type struct the easy way.
      # So, we instead use mutation to achieve "laziness."
      def lazy_type?
        false
      end

      ##
      # The lazy version of this type, for mutual recursion.
      # @see #lazy_type? for why this is needed
      #
      # Once you call {#finalize_lazy_type!}, the type will be "fleshed out," and can be actually used.
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
      # @abstract
      def serialize(_object, _options = {})
        raise ArgumentError, 'not implemented!'
      end

      ##
      # Get the type that we serialize to.
      # @abstract
      def type
        raise ArgumentError, 'not implemented!'
      end

      ##
      # Returns self.
      #
      # This exists due to a hack.
      def serializer
        self
      end

      ##
      # @overload identifier()
      #   Returns the external identifier, used to uniquely identify this object within
      #   the schemas section of an OpenAPI v3 document.
      #   @return [String] the identifier.
      # @overload identifier(arg)
      #   Sets the external identifier to use to uniquely identify
      #   this object within the schemas section of an OpenAPI v3 document.
      #   @param arg [String] the identifier to use
      #   @return [String] the identifer set
      def identifier(arg = nil)
        @identifier = arg if arg
        @identifier
      end
    end
  end
end
