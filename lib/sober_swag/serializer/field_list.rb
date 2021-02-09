module SoberSwag
  module Serializer
    ##
    # Extracts a JSON hash from a list of {SoberSwag::OutputObject::Field} structs.
    class FieldList < Base
      ##
      # Create a new field-list serializer.
      #
      # @param field_list [Array<SoberSwag::OutputObject::Field>] descriptions of each field
      def initialize(field_list)
        @field_list = field_list
      end

      ##
      # @return [Array<SoberSwag::OutputObject::Field>] the list of fields to use.
      attr_reader :field_list

      ##
      # Alias to make writing primitive stuff much easier
      def primitive(symbol)
        SoberSwag::Serializer.Primitive(SoberSwag::Types.const_get(symbol))
      end

      ##
      # Serialize an object to a JSON hash by using each field in the list.
      def serialize(object, options = {})
        field_list.map { |field|
          [field.name, field.serializer.serialize(object, options)]
        }.to_h
      end

      ##
      # Construct a Dry::Struct from the fields given.
      # This Struct will be swagger-able.
      # @return [Dry::Struct]
      def type
        @type ||= make_struct_type!
      end

      ##
      # These types are always constructed lazily.
      def lazy_type?
        true
      end

      def lazy_type
        struct_class
      end

      def finalize_lazy_type!
        make_struct_type!
      end

      private

      def make_struct_type! # rubocop:disable Metrics/MethodLength
        # mutual recursion makes this really, really annoying.
        return struct_class if @made_struct_type

        f = field_list
        s = identifier
        struct_class.instance_eval do
          identifier(s)
          f.each do |field|
            attribute field.name, field.serializer.lazy_type
          end
        end
        @made_struct_type = true

        field_list.map(&:serializer).each(&:finalize_lazy_type!)

        struct_class
      end

      def struct_class
        @struct_class ||= Class.new(SoberSwag::InputObject)
      end
    end
  end
end
