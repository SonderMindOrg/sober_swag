module SoberSwag
  class Compiler
    ##
    # A compiler for swagger-able types.
    #
    # This class turns Swagger-able types into a *schema*.
    # This Schema may be:
    # - a [schema object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#schemaObject) with {#object_schema}
    # - a [path schema](https://swagger.io/docs/specification/describing-parameters/#path-parameters) with {#path_schema}
    # - a [query schema](https://swagger.io/docs/specification/describing-parameters/#query-parameters) with {#query_schema}
    #
    # As such, it compiles all types to all applicable schemas.
    #
    # While this class compiles *one* type at a time, it *keeps track* of the other types needed to describe this schema.
    # It stores these types in a set, available at {#found_types}.
    #
    # For example, with a schema like:
    #
    # ```ruby
    # class Bar < SoberSwag::InputObject
    #   attribute :baz, primitive(:String)
    # end
    #
    # class Foo < SoberSwag::InputObject
    #   attribute :bar, Bar
    # end
    # ```
    #
    # If you compile `Foo` with this class, {#found_types} will include `Bar`.
    #
    class Type # rubocop:disable Metrics/ClassLength
      ##
      # An error raised when a type is too complicated for a given schema.
      # This may be due to containing too many layers of nesting.
      class TooComplicatedError < ::SoberSwag::Compiler::Error; end
      ##
      # An error raised when a type is too complicated to transform into a *path* schema.
      class TooComplicatedForPathError < TooComplicatedError; end
      ##
      # An error raised when a type is too complicated to transform into a *query* schema.
      class TooComplicatedForQueryError < TooComplicatedError; end

      ##
      # A list of acceptable keys to use as metadata for an object schema.
      # All other metadata keys defined on a type with {SoberSwag::InputObject.meta} will be ignored.
      #
      # @return [Array<Symbol>] valid keys.
      METADATA_KEYS = %i[description deprecated].freeze

      ##
      # Create a new compiler for a swagger-able type.
      # @param type [Class] the type to compile
      def initialize(type)
        @type = type
      end

      ##
      # @return [Class] the type we are compiling.
      attr_reader :type

      ##
      # Is this type standalone, IE, worth serializing on its own
      # in the schemas section of our schema?
      # @return [true,false]
      def standalone?
        type.is_a?(Class)
      end

      ##
      # Get back the [schema object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#schemaObject)
      # for the type described.
      #
      # @return [Hash]
      def object_schema
        @object_schema ||=
          make_object_schema
      end

      ##
      # Give a "stub type" for this schema.
      # This is suitable to use as the schema for attributes of other schemas.
      # Almost always generates a ref object.
      # @return [Hash] the OpenAPI V3 schema stub
      def schema_stub
        @schema_stub ||= generate_schema_stub
      end

      ##
      # The schema for this type when it is path of the path.
      #
      # @raise [TooComplicatedForPathError] when the compiled type is too complicated to use in a path
      # @return [Hash] a [path parameters hash](https://swagger.io/docs/specification/describing-parameters/#path-parameters) for this type.
      def path_schema
        path_schema_stub.map do |e|
          ensure_uncomplicated(e[:name], e[:schema])
          e.merge(in: :path)
        end
      rescue TooComplicatedError => e
        raise TooComplicatedForPathError, e.message
      end

      DEFAULT_QUERY_SCHEMA_ATTRS = { in: :query, style: :deepObject, explode: true }.freeze

      ##
      # The schema for this type when it is part of the query.
      # @raise [TooComplicatedForQueryError] when this type is too complicated to use in a query schema
      # @return [Hash] a [query parameters hash](https://swagger.io/docs/specification/describing-parameters/#query-parameters) for this type.
      def query_schema
        path_schema_stub.map { |e| DEFAULT_QUERY_SCHEMA_ATTRS.merge(e) }
      rescue TooComplicatedError => e
        raise TooComplicatedForQueryError, e.message
      end

      ##
      # Get the name of this type if it is to be used in a `$ref` key.
      # This is useful if we are going to use this type compiler to compile an *attribute* of another object.
      #
      # @return [String] a reference specifier for this type
      def ref_name
        SoberSwag::Compiler::Primitive.new(type).ref_name
      end

      ##
      # Get a set of all other types needed to compile this type.
      # This set will *not* include the type being compiled.
      #
      # @return [Set<Class>]
      def found_types
        @found_types ||=
          begin
            (_, found_types) = parsed_result
            found_types
          end
      end

      ##
      # This type, parsed into an AST.
      def parsed_result
        @parsed_result ||= Parser.new(type_for_parser).run_parser
      end

      ##
      # Standard ruby equality.
      def eql?(other)
        other.class == self.class && other.type == type
      end

      ##
      # Standard ruby hasing method.
      # Compilers hash to the same value if they are compiling the same type.
      def hash
        [self.class, type].hash
      end

      private

      ##
      # Get metadata attributes to be used if compiling an object schema.
      #
      # @return [Hash]
      def object_schema_meta
        return {} unless standalone? && type <= SoberSwag::Type::Named

        {
          description: type.description
        }.reject { |_, v| v.nil? }
      end

      def parsed_type
        @parsed_type ||=
          begin
            (parsed,) = parsed_result
            parsed
          end
      end

      def mapped_type
        @mapped_type ||= parsed_type.map { |v| SoberSwag::Compiler::Primitive.new(v).type_hash }
      end

      def generate_schema_stub
        if type.is_a?(Class)
          SoberSwag::Compiler::Primitive.new(type).type_hash
        else
          object_schema
        end
      end

      def type_for_parser
        if type.is_a?(Class)
          type.schema.type
        else
          # Probably a constrained array
          type
        end
      end

      def make_object_schema(metadata_keys: METADATA_KEYS)
        normalize(mapped_type).cata { |e| to_object_schema(e, metadata_keys) }.merge(object_schema_meta)
      end

      def normalize(object)
        object.cata { |e| rewrite_sums(e) }.cata { |e| flatten_one_ofs(e) }
      end

      def rewrite_sums(object) # rubocop:disable Metrics/MethodLength
        case object
        when Nodes::Sum
          lhs, rhs = object.deconstruct
          if lhs.is_a?(Nodes::OneOf) && rhs.is_a?(Nodes::OneOf)
            Nodes::OneOf.new(lhs.deconstruct + rhs.deconstruct)
          elsif lhs.is_a?(Nodes::OneOf)
            Nodes::OneOf.new([*lhs.deconstruct, rhs])
          elsif rhs.is_a?(Nodes::OneOf)
            Nodes::OneOf.new([lhs, *rhs.deconstruct])
          else
            Nodes::OneOf.new([lhs, rhs])
          end
        else
          object
        end
      end

      def flatten_one_ofs(object)
        case object
        when Nodes::OneOf
          Nodes::OneOf.new(object.deconstruct.uniq)
        else
          object
        end
      end

      def to_object_schema(object, metadata_keys = METADATA_KEYS) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        case object
        when Nodes::List
          { type: :array, items: object.element }
        when Nodes::Enum
          { type: :string, enum: object.values }
        when Nodes::OneOf
          one_of_to_schema(object)
        when Nodes::Object
          # openAPI requires that you give a list of required attributes
          # (which IMO is the *totally* wrong thing to do but whatever)
          # so we must do this garbage
          required = object.deconstruct.filter { |(_, b)| b[:required] }.map(&:first)
          {
            type: :object,
            properties: object.deconstruct.map { |(a, b)|
              [a, b.reject { |k, _| k == :required }]
            }.to_h,
            required: required
          }
        when Nodes::Attribute
          name, req, value, meta = object.deconstruct
          value = value.merge(meta&.select { |k, _| metadata_keys.include?(k) } || {})
          if req
            [name, value.merge(required: true)]
          else
            [name, value]
          end
        when Nodes::Primitive
          object.value.merge(object.metadata.select { |k, _| metadata_keys.include?(k) })
        else
          raise ArgumentError, "Got confusing node #{object} (#{object.class})"
        end
      end

      def one_of_to_schema(object)
        if object.deconstruct.include?({ type: :null })
          rejected = object.deconstruct.reject { |e| e[:type] == :null }
          if rejected.length == 1
            rejected.first.merge(nullable: true)
          else
            { oneOf: flatten_oneofs_hash(rejected), nullable: true }
          end
        else
          { oneOf: flatten_oneofs_hash(object.deconstruct) }
        end
      end

      def flatten_oneofs_hash(object)
        object.map { |h|
          h[:oneOf] || h
        }.flatten
      end

      def path_schema_stub
        @path_schema_stub ||=
          make_object_schema(metadata_keys: METADATA_KEYS | %i[style explode])[:properties].map do |k, v|
            # ensure_uncomplicated(k, v)
            {
              name: k,
              schema: v.reject { |key, _| %i[required nullable explode style].include?(key) },
              required: object_schema[:required].include?(k) || false,
              style: v[:style],
              explode: v[:explode]
            }.reject { |_, v2| v2.nil? }
          end
      end

      def ensure_uncomplicated(key, value)
        return if value[:type]

        return value[:oneOf].each { |member| ensure_uncomplicated(key, member) } if value[:oneOf]

        raise TooComplicatedError, <<~ERROR
          Property #{key} has object-schema #{value}, but this type of param should be simple (IE a primitive of some kind)
        ERROR
      end
    end
  end
end
