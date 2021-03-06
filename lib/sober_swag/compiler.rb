module SoberSwag
  ##
  # Compiler for an entire API.
  #
  # This compiler has a *lot* of state as we need to get
  class Compiler
    autoload(:Type, 'sober_swag/compiler/type')
    autoload(:Error, 'sober_swag/compiler/error')
    autoload(:Primitive, 'sober_swag/compiler/primitive')
    autoload(:Path, 'sober_swag/compiler/path')
    autoload(:Paths, 'sober_swag/compiler/paths')

    def initialize
      @types = Set.new
      @paths = Paths.new
    end

    ##
    # Convert a compiler to the overall type definition.
    #
    # @return Hash the swagger definition.
    def to_swagger
      {
        paths: path_schemas,
        components: {
          schemas: object_schemas
        }
      }
    end

    ##
    # Add a path to be compiled.
    # @param route [SoberSwag::Controller::Route] the route to add.
    # @return [Compiler] self
    def add_route(route)
      tap { @paths.add_route(route) }
    end

    ##
    # Get the schema of each object type defined in this Compiler.
    #
    # @return [Hash]
    def object_schemas
      @types.map { |v| [v.ref_name, v.object_schema] }.to_h
    end

    ##
    # The path section of the swagger schema.
    #
    # @return [Hash]
    def path_schemas
      @paths.paths_list(self)
    end

    ##
    # Compile a type to a new, path-params list.
    # This will add all subtypes to the found types list.
    #
    # @param type [Class] the type to get a path_params definition for
    # @return [Hash]
    def path_params_for(type)
      with_types_discovered(type).path_schema
    end

    ##
    # Get the query params list for a type.
    # All found types will be added to the reference dictionary.
    #
    # @param type [Class] the type to get the query_params definitions for
    # @return [Hash]
    def query_params_for(type)
      with_types_discovered(type).query_schema
    end

    ##
    # Get the request body definition for a type.
    # This will always be a ref.
    #
    # @param type [Class] the type to get the body definition for
    # @return [Hash]
    def body_for(type)
      add_type(type)
      Type.new(type).schema_stub
    end

    ##
    # Get the definition of a response type.
    #
    # This is an alias of {#body_for}
    # @see body_for
    def response_for(type)
      body_for(type)
    end

    ##
    # Get the existing schema for a given type.
    #
    # @param type [Class] the type to get the schema for
    # @return [Hash,nil] the swagger schema for this object, or nil if it was not found.
    def schema_for(type)
      @types.find { |type_comp| type_comp.type == type }&.object_schema
    end

    ##
    # Add a type in the types reference dictionary, essentially.
    # @param type [Class] the type to compiler
    # @return [SoberSwag::Compiler] self
    def add_type(type)
      # use tap here to avoid an explicit self at the end of this
      # which makes this method chainable
      tap do
        type_compiler = Type.new(type)

        ##
        # Do nothing if we already have a type
        return self if @types.include?(type_compiler)

        @types.add(type_compiler) if type_compiler.standalone?

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
