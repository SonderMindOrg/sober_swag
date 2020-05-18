module SoberSwag
  class Blueprint
    class View

      def self.define(name, base_fields, &block)
        self.new(name, base_fields).tap do |view|
          view.instance_eval(&block)
        end
      end

      class NestingError < Error; end;

      include FieldSyntax

      def initialize(name, base_fields = [])
        @name = name
        @fields = base_fields.dup
      end

      attr_reader :name, :fields

      def except!(name)
        @fields.select! { |f| f.name != name }
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
          SoberSwag::Serializer::FieldList.new(fields)
      end

    end
  end
end
