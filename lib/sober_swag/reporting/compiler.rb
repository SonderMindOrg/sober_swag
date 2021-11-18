module SoberSwag
  module Reporting
    module Compiler
      ##
      # Compile component schemas.
      class Schema
        def initialize
          @references = {}
          @referenced_schemas = Set.new
        end

        ##
        # Hash of references to type definitions.
        # Suitable for us as the components hash.
        attr_reader :references

        def compile(value)
          compile_inner(value.swagger_schema)
        end

        def compile_inner(value)
          initial, found = value

          merge_found(found)

          initial
        end

        def merge_found(found)
          found.each do |k, v|
            next unless @referenced_schemas.add?(k)

            @references[k] = compile_inner(v.call)
          end
        end
      end
    end
  end
end
