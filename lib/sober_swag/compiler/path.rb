module SoberSwag
  class Compiler
    ##
    # This compiler transforms a {SoberSwag::Controller::Route} object into its associated OpenAPI V3 definition.
    # These definitions are [called "paths" in the OpenAPI V3 spec](https://swagger.io/docs/specification/paths-and-operations/),
    # thus the name of this compiler.
    #
    # It only compiles a *single* "path" at a time.
    class Path
      ##
      # @param route [SoberSwag::Controller::Route] a route to use
      # @param compiler [SoberSwag::Compiler] the compiler to use for type compilation
      def initialize(route, compiler)
        @route = route
        @compiler = compiler
      end

      ##
      # @return [SoberSwag::Controller::Route]
      attr_reader :route

      ##
      # @return [SoberSwag::Compiler] the compiler used for type compilation
      attr_reader :compiler

      ##
      # The OpenAPI V3 "path" object for the associated {SoberSwag::Controller::Route}
      #
      # @return [Hash] the OpenAPI V3 description
      def schema
        base = {}
        base[:summary] = route.summary if route.summary
        base[:description] = route.description if route.description
        base[:parameters] = params if params.any?
        base[:responses] = responses
        base[:requestBody] = request_body if request_body
        base[:tags] = tags if tags
        base
      end

      ##
      # An array of "response" objects from swagger.
      #
      # @return [Hash{String => Hash}]
      #   response code to response object.
      def responses # rubocop:disable Metrics/MethodLength
        route.response_serializers.map { |status, serializer|
          [
            status.to_s,
            {
              description: route.response_descriptions[status],
              content: {
                'application/json': {
                  schema: compiler.response_for(
                    serializer.respond_to?(:swagger_schema) ? serializer : serializer.type
                  )
                }
              }
            }
          ]
        }.to_h
      end

      ##
      # An array of all parameters, be they in the query or in the path.
      # See [this page](https://swagger.io/docs/specification/serialization/) for what that looks like.
      #
      # @return [Array<Hash>]
      def params
        query_params + path_params
      end

      ##
      # An array of schemas for all query parameters.
      #
      # @return [Array<Hash>] the schemas
      def query_params
        if route.query_params_class
          compiler.query_params_for(route.query_params_class)
        else
          []
        end
      end

      ##
      # An array of schemas for all path parameters.
      #
      # @return [Array<Hash>] the schemas
      def path_params
        if route.path_params_class
          compiler.path_params_for(route.path_params_class)
        else
          []
        end
      end

      ##
      # The schema for a request body.
      # Matches [this spec.](https://swagger.io/docs/specification/paths-and-operations/)
      #
      # @return [Hash] the schema
      def request_body
        return nil unless route.request_body_class

        {
          required: true,
          content: {
            'application/json': {
              schema: compiler.body_for(route.request_body_class)
            }
          }
        }
      end

      ##
      # The tags for this path.
      # @return [Array<String>] the tags
      def tags
        return nil unless route.tags.any?

        route.tags
      end
    end
  end
end
