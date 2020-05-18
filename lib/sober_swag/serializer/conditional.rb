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
    class Conditional < Base
      ##
      # Error thrown when a chooser proc returns a non left-or-right value.
      class BadChoiceError < Error; end

      def initialize(chooser, left, right)
        @chooser = chooser
        @left = left
        @right = right
      end

      attr_reader :chooser, :left, :right

      def extraction
        @extractor ||= Proc.new do |object, options = {}|
          tag, val = chooser.call(object, options)
          if tag == :left
            left.serialize(val, options)
          elsif tag == :right
            right.serialize(val, options)
          else
            raise BadChoiceError, "result of chooser proc was not a left or right, but a #{val.class}"
          end
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
    end
  end
end
