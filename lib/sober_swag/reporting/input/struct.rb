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
      class Struct
        class << self
          ##
          # Define a new attribute, which will be required.
          # @param name [Symbol] the name of this attribute
          # @param input [Interface] input reporting type
          # @param description [String,nil] description for this attribute
          def attribute(name, input, description: nil)
            add_attribute!(name, input, required: true, description: description)
          end

          ##
          # Define a new attribute, which will not be required.
          # @param name [Symbol] the name of this attribute
          # @param input [Interface] input reporting type
          # @param description [String,nil] description for this attribute
          def attribute?(name, input, description: nil)
            add_attribute!(name, input, required: false, description: description)
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

          def object_properties
            @object_properties ||= {}
          end

          def inherited(other)
            other.object_properties.merge!(object_properties)
          end

          include Interface

          def input_type
            object_type.mapped { |x| new(x) }.referenced(identifier)
          end

          def identifier(val = nil)
            if val
              @identifier = val
            else
              @identifier || name&.gsub('::', '.')
            end
          end

          def call(attrs)
            input_type.call(attrs)
          end

          def parse(json)
            call(json)
          end

          def parse!(json)
            call!(json)
          end

          def swagger_schema
            input_type.swagger_schema
          end

          private

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
            Object.new(object_properties)
          end
        end

        def initialize(props)
          @struct_properties = props
        end

        attr_reader :struct_properties

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
          @struct_properties
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
