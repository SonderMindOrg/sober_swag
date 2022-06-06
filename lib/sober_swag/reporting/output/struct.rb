module SoberSwag
  module Reporting
    module Output
      ##
      # A DSL for building "output object structs."
      class Struct # rubocop:disable Metrics/ClassLength
        class << self
          include Interface

          ##
          # Define a new field to be serialized.
          #
          # @param name [Symbol] name of this field.
          # @param output [Interface] reporting output to use to serialize.
          # @param description [String,nil] description for this field.
          # @param block [Proc, nil]
          #   If a block is given, it will be defined as a method on the output object struct.
          #   If the block takes an argument, the object being serialized will be passed to it.
          #   Otherwise, it will be accessible as `#object_to_serialize` from within the body.
          #
          #   You can access other methods from this method.
          def field(name, output, description: nil, &extract)
            raise ArgumentError, bad_field_message(name, output) unless output.is_a?(Interface)

            define_field(name, extract)

            object_fields[name] = Object::Property.new(
              output.view(:base).via_map(&name.to_proc),
              description: description
            )
          end

          def object_output
            base = Object.new(object_fields).via_map { |o| new(o) }
            if description
              base.described(description)
            else
              base
            end
          end

          ##
          # Set a description for the *type* of this output.
          # It will show up as a description in the component key for this output.
          # Right now that unfortunately will not render with ReDoc, but it should eventually.
          #
          # @param val [String, nil] pass if you want to set, otherwise you will get the current value
          # @return [String] the description assigned to this object, if any.
          def description(val = nil)
            return @description unless val

            @description = val
          end

          ##
          # An output for this specific schema type.
          # If this schema has any views, it will be defined as a map of possible views to the actual views used.
          # Otherwise, it will directly be the base definition.
          def single_output
            single =
              if view_map.any?
                Viewed.new(identified_view_map)
              else
                inherited_output
              end
            identifier ? single.referenced(identifier) : single
          end

          ##
          # Used to generate 'allOf' subtyping relationships.
          # Probably do not call this yourself.
          #
          # @return [Interface]
          def identified_with_base
            object_output.referenced([identifier, 'Base'].join('.'))
          end

          ##
          # Used to generate 'allOf' subtyping relationships.
          # Probably do not call this yourself.
          def identified_without_base
            if parent_struct
              MergeObjects
                .new(parent_struct.inherited_output, object_output)
            else
              object_output
            end.referenced(identifier)
          end

          ##
          # Used to generate 'allOf' subtyping relationships.
          # Probably do not call this yourself!
          # Use {#single_output} instead.
          #
          # This allows us to implement *inheritance*.
          # So, if you inherit from another output object struct, you get its methods and attributes.
          # Views behave as if they have inherited the base object.
          #
          # This means that any views added to any parent output objects *will* be visible in children.
          # @return [Interface]
          def inherited_output
            inherited =
              if parent_struct
                MergeObjects
                  .new(parent_struct.inherited_output, object_output)
              else
                object_output
              end

            identifier ? inherited.referenced([identifier, 'Base'].join('.')) : inherited
          end

          ##
          # Schema for this output.
          # Will include views, if applicable.
          def swagger_schema
            single_output.swagger_schema
          end

          ##
          # Serialize an object to a hash.
          #
          # @param value [Object] value to serialize
          # @param view [Symbol] which view to use to serialize this output.
          # @return [Hash] the serialized ruby hash, suitable for passing to JSON.generate
          def call(value, view: :base)
            view(view).output.call(value)
          end

          ##
          # Serialize an object to a hash, with type-checking.
          #
          # @param value [Object] value to serialize
          # @param view [Symbol] which view to use
          # @return [Hash] the serialized ruby hash, suitable for passsing to JSON.generate
          def serialize_report(value, view: :base)
            view(view).output.serialize_report(value)
          end

          ##
          # @return [Hash<Symbol, Object::Property>] the properties defined *directly* on this object.
          #   Does not include inherited fields!
          def object_fields
            @object_fields ||= {}
          end

          ##
          # Define a view for this object.
          #
          # Views behave like their own output structs, which inherit the parent (or 'base' view).
          # This means that fields *after* the definition of a view *will be present in the view*.
          # This enables views to maintain a subtyping relationship.
          #
          # Your base view should thus serialize *as little as possible*.
          #
          # View classes get defined as child constants.
          # So, if I write `define_view(:foo)` on a struct called `Person`,
          # I will get `Person::Foo` as a class I can use if I want!
          #
          # @param name [Symbol] name of this view.
          # @yieldself [self] a block in which you can add more fields to the view.
          # @return [Class]
          def define_view(name, &block)
            define_view_with_parent(name, self, block)
          end

          ##
          # Defines a view for this object, which "inherits" another view.
          # @see #define_view for how views behave.
          #
          # @param name [Symbol] name of this view
          # @param inherits [Symbol] name of the view this view inherits
          # @yieldself [self] a block in which you can add more fields to this view
          # @return [Class]
          def define_inherited_view(name, inherits:, &block)
            define_view_with_parent(name, view_class(inherits), block)
          end

          ##
          # @return Hash<Symbol,Class> map of potential views.
          #   Does not include the 'base' view.
          def view_map
            @view_map ||= {}
          end

          ##
          # @return [Set<Symbol>] all applicable views.
          #   Will always include `:base`.
          def views
            [:base, *view_map.keys].to_set
          end

          ##
          # @param name [Symbol] which view to use.
          # @return [Interface] a serializer suitable for this interface.
          def view(name)
            return inherited_output if name == :base

            view_map.fetch(name).view(:base)
          end

          ##
          # Equivalent to .view, but returns the raw view class.
          #
          # @return [Class]
          def view_class(name)
            return self if name == :base

            view_map.fetch(name)
          end

          attr_accessor :parent_struct

          ##
          # When this class is inherited, it sets up a future subtyping relationship.
          # This gets expressed with 'allOf' in the generated swagger.
          def inherited(other)
            other.parent_struct = self unless self == ::SoberSwag::Reporting::Output::Struct
          end

          ##
          # Set a new identifier for this output object.
          #
          # @param value [String, nil] provide a new identifier to use.
          #   Stateful operation.
          # @return [String] identifier key to use in the components hash.
          #   In rare cases (a class with no name and no set identifier) it can return nil.
          #   We consider this case "unsupported", IE, please do not do that.
          def identifier(value = nil)
            if value
              @identifier = value
            else
              @identifier || name&.gsub('::', '.')
            end
          end

          private

          def bad_field_message(name, field_type)
            [
              "Output type used for field #{name.inspect} was",
              "#{field_type.inspect}, which is not an instance of",
              SoberSwag::Reporting::Output::Interface.name
            ].join(' ')
          end

          def define_view_with_parent(name, parent, block)
            raise ArgumentError, "duplicate view #{name}" if name == :base || views.include?(name)

            classy_name = name.to_s.classify
            us = self # grab this so its identifier doesn't get nested under whatever parent it inherits from, since its our view

            Class.new(parent).tap do |c|
              c.instance_eval(&block)
              c.define_singleton_method(:define_view) { |*| raise ArgumentError, 'no nesting views' }
              c.define_singleton_method(:identifier) { [us.identifier, classy_name.gsub('::', '.')].join('.') }
              const_set(classy_name, c)
              view_map[name] = c
            end
          end

          def identified_view_map
            view_map.transform_values(&:identified_without_base).merge(base: inherited_output)
          end

          def define_field(method, extractor)
            e =
              if extractor.nil?
                proc { _struct_serialized.public_send(method) }
              elsif extractor.arity == 1
                proc { extractor.call(_struct_serialized) }
              else
                extractor
              end

            define_method(method, &e)
          end
        end

        def initialize(struct_serialized)
          @_struct_serialized = struct_serialized
        end

        attr_reader :_struct_serialized

        ##
        # The object to serialize.
        # Use this if you're defining your own methods.
        def object_to_serialize
          @_struct_serialized
        end
      end
    end
  end
end
