module SoberSwag
  class OutputObject
    ##
    # DSL for defining a view.
    # Used in `view` blocks within {SoberSwag::OutputObject.define}.
    #
    # Views are "variants" of {SoberSwag::OutputObject}s that contain
    # different fields.
    class View < SoberSwag::Serializer::Base
      ##
      # Define a new view with the given base fields.
      # @param name [Symbol] name for this view
      # @param base_fields [Array<SoberSwag::OutputObject::Field>] fields already defined
      # @yieldself [SoberSwag::OutputObject::View]
      #
      # @return [SoberSwag::OutputObject::View]
      def self.define(name, base_fields, &block)
        new(name, base_fields).tap do |view|
          view.instance_eval(&block)
        end
      end

      ##
      # An error thrown when you try to nest views inside views.
      class NestingError < Error; end

      include FieldSyntax

      ##
      # @param name [Sybmol] name for this view.
      # @param base_fields [Array<SoberSwag::OutputObject::Field>] already-defined fields.
      def initialize(name, base_fields = [])
        @name = name
        @fields = base_fields.dup
      end

      ##
      # @return [Symbol] the name of this view
      attr_reader :name

      ##
      # @return [Array<SoberSwag::OutputObject::Fields>] the fields defined in this view.
      attr_reader :fields

      ##
      # Serialize an object according to this view.
      # @param object what to serialize
      # @param opts [Hash] arbitrary options
      # @return [Hash] the serialized result
      def serialize(obj, opts = {})
        serializer.serialize(obj, opts)
      end

      ##
      # Get the type of this view.
      # @return [Class] the type, a subclass of {Dry::Struct}
      def type
        serializer.type
      end

      ##
      # Excludes a field with the given name from this view.
      # @param name [Symbol] field to exclude.
      # @return [nil] nothing interesting
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
      # @param field [SoberSwag::OutputObject::Field]
      # @return [nil] nothing interesting
      def add_field!(field)
        @fields << field
      end

      ##
      # Pretty show for humans
      # @return [String]
      def to_s
        "<SoberSwag::OutputObject::View(#{identifier})>"
      end

      ##
      # Get the serializer defined by this view.
      # WARNING: Don't add more fields after you call this.
      #
      # @return [SoberSwag::Serializer::FieldList]
      def serializer
        @serializer ||=
          SoberSwag::Serializer::FieldList.new(fields).tap { |s| s.identifier(identifier) }
      end
    end
  end
end
