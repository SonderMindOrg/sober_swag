module SoberSwag
  class Compiler
    ##
    # Compiles a primitive type.
    # Almost always constructed with the values from
    # {SoberSwag::Nodes::Primitive}.
    class Primitive
      def initialize(type)
        @type = type

        raise Error, "#{type.inspect} is not a class!" unless @type.is_a?(Class)
      end

      attr_reader :type

      def swagger_primitive?
        SWAGGER_PRIMITIVE_DEFS.include?(type)
      end

      ##
      # Is the wrapped type a named type, causing us to make a ref?
      def named?
        type <= SoberSwag::Type::Named
      end

      ##
      # Turn this type into a swagger hash with a proper type key.
      def type_hash
        if swagger_primitive?
          SWAGGER_PRIMITIVE_DEFS.fetch(type)
        else
          {
            oneOf: [
              { '$ref'.to_sym => named_ref }
            ]
          }
        end
      end

      DATE_PRIMITIVE = { type: :string, format: :date }.freeze
      DATE_TIME_PRIMITIVE = { type: :string, format: :'date-time' }.freeze
      HASH_PRIMITIVE = { type: :object, additionalProperties: true }.freeze

      SWAGGER_PRIMITIVE_DEFS =
        {
          NilClass => :null,
          TrueClass => :boolean,
          FalseClass => :boolean,
          Float => :number,
          Integer => :integer,
          String => :string
        }.transform_values { |v| { type: v.freeze } }
        .to_h.merge(
          Date => DATE_PRIMITIVE,
          DateTime => DATE_TIME_PRIMITIVE,
          Time => DATE_TIME_PRIMITIVE,
          Hash => HASH_PRIMITIVE
        ).transform_values(&:freeze).freeze

      def ref_name
        raise Error, 'is not a type that is named!' if swagger_primitive?

        if type <= SoberSwag::Type::Named
          type.root_alias.identifier
        else
          type.name.gsub('::', '.')
        end
      end

      private

      def named_ref
        "#/components/schemas/#{ref_name}"
      end
    end
  end
end
