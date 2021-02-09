module SoberSwag
  class OutputObject
    ##
    # DSL for defining a view.
    # Used in `view` blocks within {SoberSwag::OutputObject.define}.
    #
    # Views are "variants" of {SoberSwag::OutoutObject}s that contain
    # different fields.
    class View < SoberSwag::Serializer::Base
      ##
      # Define a new view with the given base fields.
      def self.define(name, base_fields, &block)
        new(name, base_fields).tap do |view|
          view.instance_eval(&block)
        end
      end

      ##
      # An error thrown when you try to nest views inside views.
      class NestingError < Error; end

      include FieldSyntax

      def initialize(name, base_fields = [])
        @name = name
        @fields = base_fields.dup
      end

      attr_reader :name, :fields

      ##
      # Serialize an object according to this view.
      def serialize(obj, opts = {})
        serializer.serialize(obj, opts)
      end

      ##
      # Get the type of this view.
      def type
        serializer.type
      end

      ##
      # Excludes a field with the given name from this view.
      # @param name [Symbol] field to exclude.
      def except!(name)
        @fields.reject! { |f| f.name == name }
      end

      ##
      # Always raises {NestingError}
      # @raise {NestingError} always
      def view(*)
        raise NestingError, 'no views in views'
      end

      ##
      # Adds a field do this view.
      def add_field!(field)
        @fields << field
      end

      ##
      # Pretty show for humans
      def to_s
        "<SoberSwag::OutputObject::View(#{identifier})>"
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
