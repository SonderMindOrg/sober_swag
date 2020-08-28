module SoberSwag
  class Compiler
    ##
    # A compiler for DRY-Struct data types, essentially.
    # It only consumes one type at a time.
    class Type # rubocop:disable Metrics/ClassLength
      class TooComplicatedError < ::SoberSwag::Compiler::Error; end
      class TooComplicatedForPathError < TooComplicatedError; end
      class TooComplicatedForQueryError < TooComplicatedError; end

      METADATA_KEYS = %i[description deprecated].freeze

      def initialize(type)
        @type = type
      end

      attr_reader :type

      ##
      # Is this type standalone, IE, worth serializing on its own
      # in the schemas section of our schema?
      def standalone?
        type.is_a?(Class)
      end

      def object_schema
        @object_schema ||=
          normalize(mapped_type).cata(&method(:to_object_schema)).merge(object_schema_meta)
      end

      def object_schema_meta
        return {} unless standalone? && type <= SoberSwag::Type::Named

        {
          description: type.description
        }.reject { |_, v| v.nil? }
      end

      def schema_stub
        @schema_stub ||= generate_schema_stub
      end

      def path_schema
        path_schema_stub.map do |e|
          ensure_uncomplicated(e[:name], e[:schema])
          e.merge(in: :path)
        end
      rescue TooComplicatedError => e
        raise TooComplicatedForPathError, e.message
      end

      def query_schema
        path_schema_stub.map { |e| e.merge(in: :query, style: :deepObject, explode: true) }
      rescue TooComplicatedError => e
        raise TooComplicatedForQueryError, e.message
      end

      def ref_name
        SoberSwag::Compiler::Primitive.new(type).ref_name
      end

      def found_types
        @found_types ||=
          begin
            (_, found_types) = parsed_result
            found_types
          end
      end

      def mapped_type
        @mapped_type ||= parsed_type.map { |v| SoberSwag::Compiler::Primitive.new(v).type_hash }
      end

      def parsed_type
        @parsed_type ||=
          begin
            (parsed,) = parsed_result
            parsed
          end
      end

      def parsed_result
        @parsed_result ||= Parser.new(type_for_parser).run_parser
      end

      def eql?(other)
        other.class == self.class && other.type == type
      end

      def hash
        [self.class, type].hash
      end

      private

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

      def to_object_schema(object) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
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
          name, req, value = object.deconstruct
          if req
            [name, value.merge(required: true)]
          else
            [name, value]
          end
        when Nodes::Primitive
          object.value.merge(object.metadata.select { |k, _| METADATA_KEYS.include?(k) })
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
          object_schema[:properties].map do |k, v|
            # ensure_uncomplicated(k, v)
            {
              name: k,
              schema: v.reject { |key, _| %i[required nullable].include?(key) },
              required: object_schema[:required].include?(k) || false
            }
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
