module SoberSwag
  module Serializer
    ##
    # Conditionally serialize one thing *or* the other thing via deciding on a condition.
    # This works by taking three elements: a "decision" proc, a "left" serializer, and a "right" serializer.
    # The decision proc takes in both the object to be serialized *and* the options hash, and returns a
    # `[:left, val]` object, or a `[:right, val]` object, which
    # then get passed on to the appropriate serializer.
    #
    # This is a very weird, not-very-Ruby-like abstraction, *upon which* we can build abstractions that are actually use for users.
    # It lets you build abstractions like "Use this serializer if a type has this class, otherwise use this other one."
    # When composed together, you can make arbitrary decision trees.
    #
    # This class is heavily inspired by
    # the [Decideable](https://hackage.haskell.org/package/contravariant-1.5.3/docs/Data-Functor-Contravariant-Divisible.html#t:Decidable)
    # typeclass from Haskell.
    class Conditional < Base
      ##
      # Error thrown when a chooser proc returns a non left-or-right value.
      class BadChoiceError < Error; end

      ##
      # Create a new conditional serializer, from a "chooser" proc, a "left" serializer, and a "right" serializer.
      #
      # @param chooser [Proc,Lambda] the proc that chooses which "side" to use
      # @param left [SoberSwag::Serializer::Base] a serializer for the "left" side
      # @param right [SoberSwag::Serializer::Base] a serializer for the "right" side
      def initialize(chooser, left, right)
        @chooser = chooser
        @left = left
        @right = right
      end

      ##
      # @return [Proc,Lambda] the "chooser" proc.
      attr_reader :chooser

      ##
      # @return [SoberSwag::Serializer::Base] the serializer to use if the "chooser" proc chooses `:right`.
      #   Also called the "left-side serializer."
      attr_reader :left

      ##
      # @return [SoberSwag::Serializer::Base] the serializer to use if the "chooser" proc chooses `:right`.
      #   Also called the "right-side serializer."
      attr_reader :right

      ##
      # First, call {#chooser} with `object` and `options` to see what serializer to use, and *what* to serialize.
      # Then, if it returns `[:left, val]`, use {#left} to serialize `val`.
      # Otherwise, if it returns `[:right, val]`, use {#right} to serialize `val`.
      # If it returns neither, throw `BadChoiceError`.
      #
      # @raise [BadChoiceError] if {#chooser} did not choose what side to use
      # @return [Hash] a JSON-compatible object
      def serialize(object, options = {})
        tag, val = chooser.call(object, options)
        case tag
        when :left
          left.serialize(val, options)
        when :right
          right.serialize(val, options)
        else
          raise BadChoiceError, "result of chooser proc was not a left or right, but a #{val.class}"
        end
      end

      ##
      # Since this could potentially serialize one of two alternatives,
      # the "type" we serialize two is *either* one alternative or the other.
      def type
        if left.type == right.type
          left.type
        else
          left.type | right.type
        end
      end

      def lazy_type
        if left.lazy_type == right.lazy_type
          left.lazy_type
        else
          left.lazy_type | right.lazy_type
        end
      end

      def lazy_type?
        left.lazy_type? || right.lazy_type?
      end

      ##
      # Finalize both {#left} and {#right}
      def finalize_lazy_type!
        [left, right].each(&:finalize_lazy_type!)
      end
    end
  end
end
