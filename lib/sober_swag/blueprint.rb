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

    def self.define(&block)
      self.new.tap { |o|
        o.instance_eval(&block)
      }.serializer_class
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

    ##
    # Instead of generating a new value-level construct,
    # this will generate a new *class*. This is so that you can
    # name this blueprint, and have the views named as sub-classes.
    # This is important as the type compiler uses class names
    # for generating refs.
    def serializer_class
      @serializer_class ||= make_serializer_class!
    end

    private

    def make_serializer_class!
      klass = Class.new(SoberSwag::Serializer::Base)
      base_serializer = SoberSwag::Serializer::FieldList.new(fields)
      # WhateverBlueprint::Base is now used as a ref
      klass.const_set(:Base, base_serializer.type)
      final_serializer = views.reduce(base_serializer) do |base, view|
        view_serializer = view.serializer
        # If we have a view :foo, its type is named
        # WhateverBlueprint::Foo
        klass.const_set(view.name.to_s.classify, view_serializer.type)
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
      klass.send(:define_method, :serialize) do |object, options = {}|
        final_serializer.serialize(object, options)
      end
      klass.send(:define_method, :type) do
        final_serializer.type
      end
      klass.send(:define_singleton_method, :type) do
        final_serializer.type
      end
      klass
    end

  end
end
