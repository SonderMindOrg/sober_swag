module SoberSwag
  class Compiler
    def initialize
      @pending = Set.new
      @finished = {}
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

    def interested
      @pending - Set.new(@finished.keys)
    end

    def next_interest
      interested.first
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
      in Nodes::Primitive[value:] if primitive?(value)
        { type: primitive_name(value) }
      in Nodes::Primitive[value:]
        { '$ref': get_ref(value) }
      end
    end

    def primitive_name(value)
      return 'null' if value == NilClass
      return 'number' if value == Integer
      return 'string' if value == String
    end

    def get_ref(klass)
      "#/components/schemas/#{safe_name(klass)}"
    end

    def safe_name(klass)
      klass.to_s.gsub('::', '_')
    end

    def primitive?(value)
      primitive_name(value) != nil
    end

    def compile_single(definition)
      definition.cata(&method(:rewrite_sums)).cata(&method(:flatten_one_ofs)).cata(&method(:to_json_api))
    end

    def to_schemas
      @finished.map { |k, v| [safe_name(k), v] }.to_h
    end

    def add_type(type)
      raise ArgumentError, 'is not a dry struct' unless type.ancestors.include?(Dry::Struct)
      (parsed, found_types) = Parser.new(type.schema.type).run_parser
      found_types.each { |t| @pending.add(t) }
      @finished[type] = compile_single(parsed)
      compile_pending!
      self
    end

    def compile_pending!
      while (i = next_interest)
        add_type(i)
      end
    end

  end
end
