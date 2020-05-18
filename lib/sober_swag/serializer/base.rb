module SoberSwag
  module Serializer
    class Base

      ##
      # Fundamentally, a serialize is a type definition, and a proc to extract a value of that type.
      def initialize(type, extraction)
        @type = type
        @extraction = extraction
      end

      attr_reader :type, :extraction

      ##
      # Actually serialize out an object, with the given options.
      def serialize(object, options = {})
        extraction.call(object, options)
      end

      ##
      # Return a new serializer that is an *array* of elements of this serializer.
      def array
        SoberSwag::Serializer::Base.new(
          SoberSwag::Types::Array.of(type),
          proc { |array, opts = {}| array.map { |a| extraction.call(a, opts) } }
        )
      end

      ##
      # Returns a serializer that will pass `nil` values on unscathed
      def optional
        SoberSwag::Serializer::Base.new(
          type.optional,
          proc do |object, opts = {}|
            if object.nil?
              object
            else
              extraction.call(object, opts)
            end
          end
        )
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
        SoberSwag::Serializer::Base.new(
          type,
          proc { |object, opts = {}| extraction.call(block.call(object), opts) }
        )
      end

    end
  end
end
