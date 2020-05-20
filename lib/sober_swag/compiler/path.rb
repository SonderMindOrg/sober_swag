module SoberSwag
  class Compiler
    ##
    # Compile a singular path, and that's it.
    # Only handles the actual body.
    class Path
      ##
      # @param route [SoberSwag::Controller::Route] a route to use
      # @param compiler [SoberSwag::Compiler] the compiler to use for type compilation
      def initialize(route, compiler)
        @route = route
        @compiler = compiler
      end

      attr_reader :route, :compiler

      def schema
        base = {}
        base[:summary] = route.summary if route.summary
        base[:description] = route.description if route.description
        base[:parameters] = params if params.any?
        base[:responses] = responses
        base[:requestBody] = request_body if request_body
        base
      end

      def responses
        route.response_serializers.map { |status, serializer|
          [
            status.to_s,
            {
              description: route.response_descriptions[status],
              content: {
                'application/json': {
                  schema: compiler.response_for(
                    serializer.respond_to?(:new) ? serializer.new.type : serializer.type
                  )
                }
              }
            }
          ]
        }.to_h
      end

      def params
        query_params + path_params
      end

      def query_params
        if route.query_params_class
          compiler.query_params_for(route.query_params_class)
        else
          []
        end
      end

      def path_params
        if route.path_params_class
          compiler.path_params_for(route.path_params_class)
        else
          []
        end
      end

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

    end
  end
end
