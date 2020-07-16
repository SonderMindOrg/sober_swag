module SoberSwag
  class Compiler
    ##
    # A compiler for DRY-Struct data types, essentially.
    # It only consumes one type at a time.
    class Type # rubocop:disable Metrics/ClassLength
      class << self
        def get_ref(klass)
          "#/components/schemas/#{safe_name(klass)}"
        end

        def safe_name(klass)
          if klass.respond_to?(:identifier)
            klass.identifier
          else
            klass.to_s.gsub('::', '.')
          end
        end

        def primitive?(value)
          primitive_def(value) != nil
        end

        def primitive_def(value)
          return nil unless value.is_a?(Class)

          if (name = primitive_name(value))
            { type: name }
          elsif value == Date
            { type: 'string', format: 'date' }
          elsif [Time, DateTime].any?(&value.ancestors.method(:include?))
            { type: 'string', format: 'date-time' }
          end
        end

        def primitive_name(value)
          return 'null' if value == NilClass
          return 'integer' if value == Integer
          return 'number' if value == Float
          return 'string' if value == String
          return 'boolean' if [TrueClass, FalseClass].include?(value)
        end
      end

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
          normalize(parsed_type).cata(&method(:to_object_schema))
      end

      def schema_stub
        @schema_stub ||= generate_schema_stub
      end

      def path_schema
        path_schema_stub.map { |e| e.merge(in: :path) }
      rescue TooComplicatedError => e
        raise TooComplicatedForPathError, e.message
      end

      def query_schema
        path_schema_stub.map { |e| e.merge(in: :query) }
      rescue TooComplicatedError => e
        raise TooComplicatedForQueryError, e.message
      end

      def ref_name
        self.class.safe_name(type)
      end

      def found_types
        @found_types ||=
          begin
            (_, found_types) = parsed_result
            found_types
          end
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

      def generate_schema_stub # rubocop:disable Metrics/MethodLength
        return self.class.primitive_def(type) if self.class.primitive?(type)

        case type
        when Class
          { :$ref => self.class.get_ref(type) }
        when Dry::Types::Constrained
          self.class.new(type.type).schema_stub
        when Dry::Types::Array::Member
          { type: :array, items: self.class.new(type.member).schema_stub }
        when Dry::Types::Sum
          { oneOf: normalize(parsed_type).elements.map { |t| self.class.new(t.value).schema_stub } }
        else
          raise ArgumentError, "Cannot generate a schema stub for #{type} (#{type.class})"
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
        in Nodes::Sum[Nodes::OneOf[*lhs], Nodes::OneOf[*rhs]]
        Nodes::OneOf.new(lhs + rhs)
        in Nodes::Sum[Nodes::OneOf[*args], rhs]
        Nodes::OneOf.new(args + [rhs])
        in Nodes::Sum[lhs, Nodes::OneOf[*args]]
        Nodes::OneOf.new([lhs] + args)
        in Nodes::Sum[lhs, rhs]
        Nodes::OneOf.new([lhs, rhs])
        else
          object
        end
      end

      def flatten_one_ofs(object)
        case object
          in Nodes::OneOf[*args]
          Nodes::OneOf.new(args.uniq)
          else
          object
        end
      end

      def to_object_schema(object) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
        case object
        in Nodes::List[element]
          {
            type: :array,
            items: element
          }
        in Nodes::Enum[values]
          {
            type: :string,
            enum: values
          }
        in Nodes::OneOf[{ type: 'null' }, b]
        b.merge(nullable: true)
        in Nodes::OneOf[a, { type: 'null' }]
        a.merge(nullable: true)
        in Nodes::OneOf[*attrs] if attrs.include?(type: 'null')
        { oneOf: attrs.reject { |e| e[:type] == 'null' }, nullable: true }
        in Nodes::OneOf[*cases]
        { oneOf: cases }
        in Nodes::Object[*attrs]
        # openAPI requires that you give a list of required attributes
        # (which IMO is the *totally* wrong thing to do but whatever)
        # so we must do this garbage
        required = attrs.filter { |(_, b)| b[:required] }.map(&:first)
        {
          type: :object,
          properties: attrs.map { |(a, b)|
            [a, b.reject { |k, _| k == :required }]
          }.to_h,
          required: required
        }
        in Nodes::Attribute[name, true, value]
        [name, value.merge(required: true)]
        in Nodes::Attribute[name, false, value]
        [name, value]
        # can't match on value directly as ruby uses `===` to match,
        # and classes use `===` to mean `is an instance of`, as
        # opposed to direct equality lmao
        in Nodes::Primitive[value:, metadata:] if self.class.primitive?(value)
        md = self.class.primitive_def(value)
        METADATA_KEYS.select(&metadata.method(:key?)).reduce(md) do |definition, key|
          definition.merge(key => metadata[key])
        end
        in Nodes::Primitive[value:]
        { '$ref': self.class.get_ref(value) }
        else
          raise ArgumentError, "Got confusing node #{object} (#{object.class})"
        end
      end

      def path_schema_stub
        @path_schema_stub ||=
          object_schema[:properties].map do |k, v|
            ensure_uncomplicated(k, v)
            {
              name: k,
              schema: v.reject { |key, _| %i[required nullable].include?(key) },
              # rubocop:disable Style/DoubleNegation
              allowEmptyValue: !object_schema[:required].include?(k) || !!v[:nullable], # if it's required, no empties, but if *nullabe*, empties are okay
              # rubocop:enable Style/DoubleNegation
              required: object_schema[:required].include?(k) || false
            }
          end
      end

      def ensure_uncomplicated(key, value)
        return if value[:type]

        raise TooComplicatedError, <<~ERROR
          Property #{key} has object-schema #{value}, but this type of param should be simple (IE a primitive of some kind)
        ERROR
      end
    end
  end
end
