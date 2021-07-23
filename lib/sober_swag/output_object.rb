require 'sober_swag/serializer'

module SoberSwag
  ##
  # Create a serializer that is heavily inspired by the "Blueprinter" library.
  # This allows you to make "views" and such inside.
  #
  # Under the hood, this is actually all based on {SoberSwag::Serializer::Base}.
  class OutputObject < SoberSwag::Serializer::Base
    autoload(:Field, 'sober_swag/output_object/field')
    autoload(:Definition, 'sober_swag/output_object/definition')
    autoload(:FieldSyntax, 'sober_swag/output_object/field_syntax')
    autoload(:View, 'sober_swag/output_object/view')

    ##
    # Use a OutputObject to define a new serializer.
    # It will be based on {SoberSwag::Serializer::Base}.
    #
    # An example is illustrative:
    #
    #     PersonSerializer = SoberSwag::OutputObject.define do
    #       field :id, primitive(:Integer)
    #       field :name, primitive(:String).optional
    #
    #       view :complex do
    #         field :age, primitive(:Integer)
    #         field :title, primitive(:String)
    #       end
    #     end
    #
    # Note: This currently will generate a new *class* that does serialization.
    # However, this is only a hack to get rid of the weird naming issue when
    # generating swagger from dry structs: their section of the schema area
    # is defined by their *Ruby Class Name*. In the future, if we get rid of this,
    # we might be able to keep this on the value-level, in which case {.define}
    # can simply return an *instance* of SoberSwag::Serializer that does
    # the correct thing, with the name you give it. This works for now, though.
    #
    # @return [Class] the serializer generated.
    def self.define(&block)
      d = Definition.new.tap do |o|
        o.instance_eval(&block)
      end
      new(d.fields, d.views, d.identifier)
    end

    ##
    # @param fields [Array<SoberSwag::OutputObject::Field>] the fields for this OutputObject
    # @param views [Array<SoberSwag::OutputObject::View>] the views for this OutputObject
    # @param identifier [String] the external identifier for this OutputObject
    def initialize(fields, views, identifier)
      @fields = fields
      @views = views
      @identifier = identifier
    end

    ##
    # @return [Array<SoberSwag::OutputObject::Field>]
    attr_reader :fields
    ##
    # @return [Array<SoberSwag::OutputObject::View>]
    attr_reader :views
    ##
    # @return [String] the external ID to use for this object
    attr_reader :identifier

    ##
    # Perform serialization.
    def serialize(obj, opts = {})
      serializer.serialize(obj, opts)
    end

    ##
    # Get a Dry::Struct of the type this OutputObject will serialize to.
    def type
      serializer.type
    end

    ##
    # Get a serializer for a single view contained in this output object.
    # Note: given `:base`, it will return a serializer for the base OutputObject
    # @param name [Symbol] the name of the view
    # @return [SoberSwag::Serializer::Base] the serializer
    def view(name)
      return base_serializer if name == :base

      @views.find { |v| v.name == name }
    end

    ##
    # A serializer for the "base type" of this OutputObject, with no views.
    def base
      base_serializer
    end

    ##
    # Compile down this to an appropriate serializer.
    # It uses {SoberSwag::Serializer::Conditional} to do view-parsing,
    # and {SoberSwag::Serializer::FieldList} to do the actual serialization.
    #
    # @todo: optimize view selection to use binary instead of linear search
    def serializer
      @serializer ||=
        begin
          view_choices = views.map { |view| [view.name.to_s, view.serializer] }.to_h
          view_choices['base'] = base_serializer
          SoberSwag::Serializer::Hash.new(view_choices, base, proc { |_, options| options[:view]&.to_s })
        end
    end

    ##
    # @return [String]
    def to_s
      "<SoberSwag::OutputObject(#{identifier})>"
    end

    ##
    # @return [SoberSwag::Serializer::FieldList] serializer for this output object.
    def base_serializer
      @base_serializer ||= SoberSwag::Serializer::FieldList.new(fields).tap do |s|
        s.identifier(identifier)
      end
    end
  end
end
