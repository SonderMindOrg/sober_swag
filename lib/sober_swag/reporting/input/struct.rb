module SoberSwag
  module Reporting
    module Input
      ##
      # Base class of input structs.
      #
      # These allow you to define both an input type and a ruby type at once.
      # They provide a fluid interface for doing so.
      #
      # Classes which inherit from {Struct} "quack like" an {Interface}, so you can use them as input type definitions.
      #
      # You should add attributes using the {.attribute} or {.attribute?} methods.
      # These also let you nest definitions, so this is okay:
      #
      # ```ruby
      # class Person < SoberSwag::Reporting::Input::Struct
      #   attribute :first_name, SoberSwag::Reporting::Input.text
      #   attribute :stats do
      #     attribute :average_score, SoberSwag::Reporting::Input.number
      #   end
      # end
      # ```
      class Struct # rubocop:disable Metrics/ClassLength
        class << self
          ##
          # @overload attribute(name, input, description: nil)
          #   Define a new attribute, which will be required.
          #   @param name [Symbol] the name of this attribute
          #   @param input [Interface] input reporting type
          #   @param description [String,nil] description for this attribute
          # @overload attribute(name, description: nil, &block)
          #   Define a new nested attribute, which will be required, using a block to describe
          #   a sub-struct. This block will immediately be evaluated to create a child struct.
          #   @param name [Symbol] the name of the attribute.
          #     The sub-struct defined will be stored in a constant on this class,
          #     under this name, classified.
          #
          #     So if the name is :first_name, then the constant will be FirstName
          #   @param description [String, nil] describe this attribute
          #   @yieldself [SoberSwag::Reporting::Input::Struct] yields
          def attribute(name, input = nil, description: nil, &block)
            input_type = make_input_type(name, input, block)
            add_attribute!(name, input_type, required: true, description: description)
          end

          ##
          # @overload attribute?(name, input, description: nil)
          #   Define a new attribute, which will be not required.
          #   @param name [Symbol] the name of this attribute
          #   @param input [Interface] input reporting type
          #   @param description [String,nil] description for this attribute
          # @overload attribute?(name, description: nil, &block)
          #   Define a new nested attribute, which will not be required, using a block to describe
          #   a sub-struct. This block will immediately be evaluated to create a child struct.
          #   @param name [Symbol] the name of the attribute.
          #     The sub-struct defined will be stored in a constant on this class,
          #     under this name, classified.
          #
          #     So if the name is :first_name, then the constant will be FirstName
          #   @param description [String, nil] describe this attribute
          #   @yieldself [SoberSwag::Reporting::Input::Struct] yields
          def attribute?(name, input, description: nil, &block)
            input_type = make_input_type(name, input, block)

            add_attribute!(name, input_type, required: false, description: description)
          end

          ##
          # Add an attribute, specifying if it is required or not via an argument.
          # You should use {#attribute} or {#attribute?} instead of this almost always.
          #
          # @param name [Symbol] name of this attribute
          # @param input [Interface] type fot this attribue
          # @param required [true,false] if this attribute is required
          # @param description [String,nil] optional description for this attribute
          #
          def add_attribute!(name, input, required:, description: nil)
            raise ArgumentError, 'name must be a symbol' unless name.is_a?(Symbol)

            define_attribute(name) # defines an instance method to access this attribute

            object_properties[name] = Object::Property.new(
              input,
              required: required,
              description: description
            )
          end

          ##
          # Get a list of properties defined by *this instance*.
          #
          # Please do not mutate this, it will break everything.
          #
          # @return [Hash<Symbol, Object::Property>]
          def object_properties
            @object_properties ||= {}
          end

          ##
          # @return [SoberSwag::Reporting::Input::Struct,nil] the struct we inherit from.
          #   Used to implement `allOf` style inheritance.
          attr_accessor :parent_struct

          ##
          # @param other [Class] the inheriting class
          #
          # Used to implement `allOf` style inheritance by setting {#parent_struct} on the object that is inheriting from us.
          def inherited(other)
            other.parent_struct = self unless self == SoberSwag::Reporting::Input::Struct
          end

          include Interface

          ##
          # @return [SoberSwag::Reporting::Input::Base] the type to use for input.
          def input_type
            object_type.mapped { |x| new(x) }.referenced(identifier)
          end

          ##
          # @overload identifier()
          #   @return [String,nil] the identifier for this object, used for its reference path.
          # @overload identifier(val)
          #   Sets an identifier for this struct.
          #   @param val [String] the identifier to set
          #   @return [String] the set identifier.
          def identifier(val = nil)
            if val
              @identifier = val
            else
              @identifier || name&.gsub('::', '.')
            end
          end

          ##
          # @return [SoberSwag::Reporting::Input::Struct, SoberSwag::Reporting::Report::Base] the struct class,
          #   or a report of what went wrong.
          def call(attrs)
            input_type.call(attrs)
          end

          ##
          # @see #call
          def parse(json)
            call(json)
          end

          ##
          # @see call!
          def parse!(json)
            call!(json)
          end

          ##
          # @return [Array[Hash, Hash]] swagger schema type.
          def swagger_schema
            input_type.swagger_schema
          end

          def swagger_query_schema
            object_type.swagger_query_schema
          end

          def swagger_path_schema
            object_type.swagger_path_schema
          end

          private

          def make_input_type(name, input, block)
            raise ArgumentError, 'cannot pass a block to make a sub-struct and a field type' if input && block

            return input if input

            raise ArgumentError, 'must pass an input type OR a block to make a sub-struct' unless block

            const_name = name.to_s.camelize

            raise ArgumentError, 'cannot define struct sub-type, constant already exists!' if const_defined?(const_name)

            Class.new(SoberSwag::Reporting::Input::Struct, &block).tap { |c| const_set(const_name, c) }
          end

          ##
          # Quick method which defines an accessor method for this struct.
          def define_attribute(name)
            define_method(name) do
              struct_properties[name]
            end
            define_method("#{name}_present?") do
              struct_properties.key?(name)
            end
          end

          def object_type
            if parent_struct.nil?
              Object.new(object_properties)
            else
              MergeObjects.new(parent_struct, Object.new(object_properties))
            end
          end
        end

        def initialize(props)
          @struct_properties = props
        end

        attr_reader :struct_properties

        def [](name)
          @struct_properties[name]
        end

        ##
        # Hash code for this struct.
        def hash
          [self.class.hash, *ordered_values.hash].hash
        end

        ##
        # Return an array of the values of this, in order.
        def ordered_values
          self.class.object_properties.keys.map { |k| @struct_properties[k] }
        end

        ##
        # Allow structs to be compared like values.
        def eql?(other)
          return false unless other.is_a?(self.class)

          ordered_values.eql?(other.ordered_values)
        end

        ##
        # Allow structs to be ordered like values.
        def <=>(other)
          return nil unless other.is_a?(self.class)

          ordered_values <=> other.ordered_values
        end

        include Comparable

        ##
        # Extracts the transformed struct properties.
        #
        # Keys not present in the input will also not be present in this hash.
        def to_h
          @struct_properties.transform_values do |value|
            if value.is_a?(SoberSwag::Reporting::Input::Struct)
              value.to_h
            else
              value
            end
          end
        end

        def to_s
          inspect
        end

        def inspect
          keys = self.class.object_properties.keys.each.with_object([]) do |k, obj|
            obj << "#{k}=#{public_send(k).inspect}" if public_send(:"#{k}_present?")
          end
          "#<#{self.class.name || self.class.inspect[2..-2]} #{keys.join(' ')}>"
        end
      end
    end
  end
end
