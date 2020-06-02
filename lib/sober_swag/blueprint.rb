require 'sober_swag/serializer'

module SoberSwag
  ##
  # Create a serializer that is heavily inspired by the "Blueprinter" library.
  # This allows you to make "views" and such inside.
  #
  # Under the hood, this is actually all based on {SoberSwag::Serialzier::Base}.
  class Blueprint
    autoload(:Field, 'sober_swag/blueprint/field')
    autoload(:Definition, 'sober_swag/blueprint/definition')
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
      d = Definition.new.tap { |o|
        o.instance_eval(&block)
      }
      self.new(d.fields, d.views, d.sober_name)
    end

    def initialize(fields, views, sober_name)
      @fields = fields
      @views = views
      @sober_name = sober_name
    end

    attr_reader :fields, :views, :sober_name

    def serialize(obj, opts = {})
      serializer.serialize(obj, opts)
    end

    def type
      serializer.type
    end

    def view(name)
      return base_serializer if name == :base

      @views.find { |v| v.name == name }
    end

    def base
      base_serializer
    end

    def serializer
      @serializer ||=
        begin
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

    def base_serializer
      @base_serializer ||= SoberSwag::Serializer::FieldList.new(fields).tap do |s|
        s.sober_name(sober_name)
      end
    end

  end
end
