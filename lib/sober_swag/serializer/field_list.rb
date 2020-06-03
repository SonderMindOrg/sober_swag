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

      def make_struct_type!
        # mutual recursion makes this really, really annoying.
        return struct_class if @made_struct_type

        f = field_list
        s = sober_name
        struct_class.instance_eval do
          sober_name(s)
          f.each do |field|
            attribute field.name, field.serializer.lazy_type
          end
        end
        @made_struct_type = true

        field_list.map(&:serializer).each(&:finalize_lazy_type!)

        struct_class
      end

      def struct_class
        @struct_class ||= Class.new(SoberSwag::Struct)
      end

    end
  end
end
