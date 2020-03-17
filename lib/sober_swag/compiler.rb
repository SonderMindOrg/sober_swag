module SoberSwag
  ##
  # Compiler for an entire API
  class Compiler
    autoload(:Type, 'sober_swag/compiler/type')

    def initialize
      @types = Set.new
    end

    def object_schemas
      @types.map { |v| [v.ref_name, v.type_definition] }.to_h
    end

    def schema_for(type)
      @types.find { |type_comp| type_comp.type == type }&.object_schema
    end

    def add_type(type)
      type_compiler = Type.new(type)

      ##
      # Do nothing if we already have a type
      return self if @types.include?(type_compiler)

      @types.add(type_compiler)

      type_compiler.found_types.each do |ft|
        add_type(ft)
      end

      self
    end
  end
end
