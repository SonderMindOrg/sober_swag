module SoberSwag
  class Compiler
    ##
    # Compile multiple routes into a paths set.
    # This basically just aggregates {SoberSwag::Controller::Route} objects.
    class Paths
      ##
      # Set up a new paths compiler with no routes in it.
      def initialize
        @routes = []
      end

      ##
      # Add on a new {SoberSwag::Controller::Route}
      #
      # @param route [SoberSwag::Controller::Route] the route description to add to compilation
      # @return [SoberSwag::Compiler::Paths] self
      def add_route(route)
        @routes << route

        self
      end

      ##
      # In the OpenAPI V3 spec, we group action definitions by their path.
      # This helps us do that.
      def grouped_paths
        routes.group_by(&:path)
      end

      ##
      # Slightly weird method that gives you a compiled
      # paths list. Since this is only a compiler for paths,
      # it has *no idea* how to handle types. So, it takes a compiler
      # which it will use to do that for it.
      #
      # @param compiler [SoberSwag::Compiler::Type] the type compiler to use
      # @return [Hash] a schema for all contained routes.
      def paths_list(compiler)
        grouped_paths.transform_values do |values|
          values.map { |route|
            [route.method, compile_route(route, compiler)]
          }.to_h
        end
      end

      ##
      # Get a list of all types we discovered when compiling
      # the paths.
      #
      # @yield [Class] all the types found in all the routes described in here.
      def found_types
        return enum_for(:found_types) unless block_given?

        routes.each do |route|
          %i[body_class query_class path_params_class].each do |k|
            yield route.public_send(k) if route.public_send(k)
          end
        end
      end

      ##
      # @return [Array<SoberSwag::Controller::Route>] the routes to document
      attr_reader :routes

      private

      def compile_route(route, compiler)
        SoberSwag::Compiler::Path.new(route, compiler).schema
      end
    end
  end
end
