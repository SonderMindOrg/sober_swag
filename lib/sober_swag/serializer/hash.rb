require 'set'

module SoberSwag
  module Serializer
    ##
    # Serialize via hash lookup.
    # This is used to speed up serialization of views, but it may be useful elsewhere.
    #
    class Hash < Base
      ##
      # @param choices [Hash<Object => SoberSwag::Serializer::Base>] hash of serializers
      #   that we might use.
      # @param default [SoberSwag::Serializer::Base] default to use if key not found.
      # @param key_proc [Proc<Object, Hash>] extract the key we are interested in from the proc.
      #   Will be called with the object to serialize and the options hash.
      def initialize(choices, default, key_proc)
        @choices = choices
        @default = default
        @key_proc = key_proc
      end

      attr_reader :choices, :default, :key_proc

      def serialize(object, options = {})
        key = key_proc.call(object, options)

        choices.fetch(key) { default }.serialize(object, options)
      end

      ##
      # @return [Set<SoberSwag::Serializer::Base>]
      def possible_serializers
        @possible_serializers ||= (choices.values + [default]).to_set
      end

      def lazy_type?
        possible_serializers.any?(&:lazy_type?)
      end

      def finalize_lazy_type!
        possible_serializers.each(&:finalize_lazy_type!)
      end

      def lazy_type
        @lazy_type ||= possible_serializers.map(&:lazy_type).reduce(:|)
      end

      def type
        @type ||= possible_serializers.map(&:type).reduce(:|)
      end
    end
  end
end
