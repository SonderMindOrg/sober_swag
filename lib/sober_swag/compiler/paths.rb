module SoberSwag
  class Compiler
    ##
    # Compile multiple routes into a paths set.
    class Paths
      def initialize
        @routes = []
      end

      def add_route(route)
        @routes << route
      end

      def grouped_paths
        routes.group_by(&:path)
      end

      ##
      # Slightly weird method that gives you a compiled
      # paths list. Since this is only a compiler for paths,
      # it has *no idea* how to handle types. So, it takes a compiler
      # which it will use to do that for it.
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
      def found_types
        return enum_for(:found_types) unless block_given?

        routes.each do |route|
          %i[body_class query_class path_params_class].each do |k|
            yield route.public_send(k) if route.public_send(k)
          end
        end
      end

      attr_reader :routes

      private

      def compile_route(route, compiler)
        SoberSwag::Compiler::Path.new(route, compiler).schema
      end

    end
  end
end
