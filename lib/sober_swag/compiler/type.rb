module SoberSwag
  class Compiler
    ##
    # A compiler for DRY-Struct data types, essentially.
    # It only consumes one type at a time.
    class Type
      class << self
        def get_ref(klass)
          "#/components/schemas/#{safe_name(klass)}"
        end

        def safe_name(klass)
          klass.to_s.gsub('::', '.')
        end

        def primitive?(value)
          primitive_name(value) != nil
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

      def initialize(type)
        raise ArgumentError, 'is not a dry struct' unless type.ancestors.include?(Dry::Struct)
        @type = type
      end

      attr_reader :type

      def object_schema
        @type_definition ||=
          normalize(parsed_type).cata(&method(:to_object_schema))
      end

      def path_schema
        path_schema_stub.map { |e| e.merge(in: :path) }
      rescue TooComplicatedError => e
        raise TooComplicatedForPathError, e.message
      end

      def query_schema
        path_schema_stub.map { |e| e.merge(in: :query) }
      rescue TooComplicatedErrror => e
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
            (parsed, _)  = parsed_result
            parsed
          end
      end

      def parsed_result
        @parsed_result ||= Parser.new(type.schema.type).run_parser
      end

      def eql?(other)
        other.class == self.class && other.type == type
      end

      def hash
        [self.class, type].hash
      end

      private

      def normalize(object)
        object.cata { |e| rewrite_sums(e) }.cata { |e| flatten_one_ofs(e) }
      end

      def rewrite_sums(object)
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

      def to_object_schema(object)
        case object
        in Nodes::OneOf[{ type: 'null' }, b]
        b.merge(nullable: true)
        in Nodes::OneOf[a, { type: 'null' }]
        a.merge(nullable: true)
        in Nodes::OneOf[*attrs] if attrs.include?(type: 'null')
        { oneOf: attrs.reject { |e| e[:type] == 'null' }, nullable: true }
        in Nodes::OneOf[*cases]
        { oneOf: cases }
        in Nodes::Object[*attrs]
        { type: :object, properties: attrs.to_h }
        in Nodes::Attribute[name, true, value]
        [name, value.merge(required: true)]
        in Nodes::Attribute[name, false, value]
        [name, value]
        # can't match on value directly as ruby uses `===` to match,
        # and classes use `===` to mean `is an instance of`, as
        # opposed to direct equality lmao
        in Nodes::Primitive[value:] if self.class.primitive?(value)
        { type: self.class.primitive_name(value) }
        in Nodes::Primitive[value:]
        { '$ref': self.class.get_ref(value) }
        end
      end

      def path_schema_stub
        @path_schema_stub ||=
          object_schema[:properties].map do |k, v|
            ensure_uncomplicated(k, v)
            {
              name: k,
              schema: v.reject { |k, _| %i[required nullable].include?(k) },
              allowEmptyValue: !v[:required] || !!v[:nullable]
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
