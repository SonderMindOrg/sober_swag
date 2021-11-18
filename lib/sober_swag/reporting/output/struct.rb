module SoberSwag
  module Reporting
    module Output
      ##
      # A DSL for building "output object structs."
      class Struct # rubocop:disable Metrics/ClassLength
        class << self
          include Interface

          def field(name, output, description: nil, &extract)
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

          def description(val = nil)
            return @description unless val

            @description = val
          end

          def single_output
            if view_map.any?
              Viewed.new(identified_view_map)
            else
              inherited_output
            end.referenced(identifier)
          end

          def identified_with_base
            object_output.referenced([identifier, 'Base'].join('.'))
          end

          def identified_without_base
            if parent_struct
              MergeObjects
                .new(parent_struct.inherited_output, object_output)
            else
              object_output
            end.referenced(identifier)
          end

          def inherited_output
            if parent_struct
              MergeObjects
                .new(parent_struct.inherited_output, object_output)
            else
              object_output
            end.referenced([identifier, 'Base'].join('.'))
          end

          def swagger_schema
            single_output.swagger_schema
          end

          def call(value, view: :base)
            view(view).output.call(value)
          end

          def object_fields
            @object_fields ||= {}
          end

          def define_view(name, &block) # rubocop:disable Metrics/MethodLength
            raise ArgumentError, "duplicate view #{name}" if name == :base || views.include?(name)

            classy_name = name.to_s.classify

            Class.new(self).tap do |c|
              c.instance_eval(&block)
              c.define_singleton_method(:define_view) do |*|
                raise ArgumentError, 'no nesting views'
              end
              c.define_singleton_method(:identifier) do
                [parent_struct.identifier, classy_name.gsub('::', '.')].join('.')
              end
              const_set(classy_name, c)
              view_map[name] = c
            end
          end

          def view_map
            @view_map ||= {}
          end

          def views
            [:base, *view_map.keys].to_set
          end

          def view(name)
            return inherited_output if name == :base

            view_map.fetch(name).view(:base)
          end

          attr_accessor :parent_struct

          def inherited(other)
            other.parent_struct = self unless self == ::SoberSwag::Reporting::Output::Struct
          end

          def identifier(value = nil)
            if value
              @identifier = value
            else
              @identifier || name.gsub('::', '.')
            end
          end

          private

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
      end
    end
  end
end
