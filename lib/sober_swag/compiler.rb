module SoberSwag
  ##
  # Compiler for an entire API
  class Compiler
    autoload(:Type, 'sober_swag/compiler/type')
    autoload(:Error, 'sober_swag/compiler/error')

    def initialize
      @types = Set.new
    end

    def object_schemas
      @types.map { |v| [v.ref_name, v.type_definition] }.to_h
    end

    ##
    # Compile a type to a new, path-params list.
    # This will add all subtypes to the found types list.
    def path_params_for(type)
      with_types_discovered(type).path_schema
    end

    ##
    # Get the query params list for a type.
    # All found types will be added to the reference dictionary.
    def query_params_for(type)
      with_types_discovered(type).query_schema
    end

    ##
    # Get the existing schema for a given type
    def schema_for(type)
      @types.find { |type_comp| type_comp.type == type }&.object_schema
    end

    ##
    # Add a type in the types reference dictionary, essentially
    def add_type(type)
      # use tap here to avoid an explicit self at the end of this
      # which makes this method chainable
      tap do
        type_compiler = Type.new(type)

        ##
        # Do nothing if we already have a type
        return self if @types.include?(type_compiler)

        @types.add(type_compiler)

        type_compiler.found_types.each do |ft|
          add_type(ft)
        end
      end
    end

    private

    def with_types_discovered(type)
      Type.new(type).tap do |type_compiler|
        type_compiler.found_types.each { |ft| add_type(ft) }
      end
    end
  end
end
