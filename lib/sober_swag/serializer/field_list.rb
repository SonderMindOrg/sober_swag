module SoberSwag
  module Serializer
    ##
    # Extract out a hash from a list of
    # name/serializer pairs.
    class FieldList < Base

      def initialize(field_list)
        @field_list = field_list
      end

      attr_reader :field_list

      ##
      # Alias to make writing primitive stuff much easier
      def primitive(symbol)
        SoberSwag::Serializer.Primitive(SoberSwag::Types.const_get(symbol))
      end


      def serialize(object, options = {})
        field_list.map { |field|
          [field.name, field.serializer.serialize(object, options)]
        }.to_h
      end

      def type
        @type ||= make_struct_type!
      end

      private

      def make_struct_type!
        f = field_list
        s = sober_name
        Class.new(SoberSwag::Struct) do
          sober_name(s)
          f.each do |field|
            attribute field.name, field.serializer.type
          end
        end
      end

    end
  end
end
