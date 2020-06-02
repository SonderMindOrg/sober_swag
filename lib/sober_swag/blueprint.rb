require 'sober_swag/serializer'

module SoberSwag
  ##
  # Create a serializer that is heavily inspired by the "Blueprinter" library.
  # This allows you to make "views" and such inside.
  #
  # Under the hood, this is actually all based on {SoberSwag::Serialzier::Base}.
  class Blueprint
    autoload(:Field, 'sober_swag/blueprint/field')
    autoload(:FieldSyntax, 'sober_swag/blueprint/field_syntax')
    autoload(:View, 'sober_swag/blueprint/view')

    ##
    # Use a Blueprint to define a new serializer.
    # It will be based on {SoberSwag::Serializer::Base}.
    #
    # An example is illustrative:
    #
    #     PersonSerializer = SoberSwag::Blueprint.define do
    #       field :id, primitive(:Integer)
    #       field :name, primtive(:String).optional
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
    # we might be able to keep this on the value-level, in which case {#define}
    # can simply return an *instance* of SoberSwag::Serializer that does
    # the correct thing, with the name you give it. This works for now, though.
    def self.define(&block)
      self.new.tap { |o|
        o.instance_eval(&block)
      }.serializer
    end

    def initialize(base_fields = [])
      @fields = base_fields.dup
      @views = []
    end

    attr_reader :fields, :views

    include FieldSyntax

    def add_field!(field)
      @fields << field
    end

    def view(name, &block)
      @views << View.define(name, fields, &block)
    end

    def sober_name(arg = nil)
      @sober_name = arg if arg
      @sober_name
    end

    def serializer
      base_serializer = SoberSwag::Serializer::FieldList.new(fields).tap do |s|
        s.sober_name(sober_name)
      end
      views.reduce(base_serializer) do |base, view|
        view_serializer = view.serializer
        view_serializer.sober_name("#{sober_name}.#{view.name.to_s.classify}") if sober_name
        SoberSwag::Serializer::Conditional.new(
          proc do |object, options|
            if options[:view].to_s == view.name.to_s
              [:left, object]
            else
              [:right, object]
            end
          end,
          view_serializer,
          base
        )
      end
    end

  end
end
