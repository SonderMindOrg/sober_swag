module SoberSwag
  class OutputObject
    ##
    # DSL for defining a view.
    # Used in `view` blocks within {SoberSwag::OutputObject.define}.
    class View < SoberSwag::Serializer::Base
      def self.define(name, base_fields, &block)
        new(name, base_fields).tap do |view|
          view.instance_eval(&block)
        end
      end

      class NestingError < Error; end

      include FieldSyntax

      def initialize(name, base_fields = [])
        @name = name
        @fields = base_fields.dup
      end

      attr_reader :name, :fields

      def serialize(obj, opts = {})
        serializer.serialize(obj, opts)
      end

      def type
        serializer.type
      end

      def except!(name)
        @fields.reject! { |f| f.name == name }
      end

      def view(*)
        raise NestingError, 'no views in views'
      end

      def add_field!(field)
        @fields << field
      end

      ##
      # Get the serializer defined by this view.
      # WARNING: Don't add more fields after you call this.
      def serializer
        @serializer ||=
          SoberSwag::Serializer::FieldList.new(fields).tap { |s| s.identifier(identifier) }
      end
    end
  end
end
