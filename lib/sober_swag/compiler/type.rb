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
          klass.to_s.gsub('::', '_')
        end

        def primitive?(value)
          primitive_name(value) != nil
        end

        def primitive_name(value)
          return 'null' if value == NilClass
          return 'number' if value == Integer
          return 'string' if value == String
        end
      end

      def initialize(type)
        raise ArgumentError, 'is not a dry struct' unless type.ancestors.include?(Dry::Struct)
        @type = type
      end

      attr_reader :type

      def type_definition
        @type_definition ||=
          begin
            (parsed, _) = parsed_result
            parsed.cata(&method(:rewrite_sums)).cata(&method(:flatten_one_ofs)).cata(&method(:to_json_api))
          end
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

      def to_json_api(object)
        case object
          in Nodes::OneOf[*cases] if cases.include?(type: 'null')
          { oneOf: cases - [{type: 'null'}], nullable: true }
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

    end
  end
end
