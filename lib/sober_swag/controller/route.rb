module SoberSwag
  class Controller
    class Route

      def initialize(controller, method, action_name, path)
        @controller = controller
        @method = method
        @path = path
        @action_name = action_name

        assign_action_module!
      end

      attr_reader :controller
      attr_reader :method
      attr_reader :path
      attr_reader :action_name
      ##
      # What to parse the request body in to.
      attr_reader :body_class
      ##
      # What to parse the request query in to
      attr_reader :query_class

      ##
      # What to parse the path params into
      attr_reader :path_params_class

      ##
      # Define the request body, using SoberSwag's type-definition scheme.
      # The block passed will be used to define the body of a new sublcass of `base` (defaulted to {Dry::Struct}.)
      # If you want, you can also define utility methods in here
      def body(base = Dry::Struct, &block)
        @body_class = make_struct!(base, &block)
        action_module.const_set('Body', @body_class)
      end

      ##
      # Define the shape of the query parameters, using SoberSwag's type-definition scheme.
      # The block passed is the body of the newly-defined type.
      # You can also include a base type.
      def query(base = Dry::Struct, &block)
        @query_class = make_struct!(base, &block)
        action_module.const_set('Query', @query_class)
      end

      ##
      # Define the shape of the *path* parameters, using SoberSwag's type-definition scheme.
      # The block passed will be the body of a new subclass of `base` (defaulted to {Dry::Struct}).
      # Names of this should match the names in the path template originally passed to {SoberSwag::Controller#define}
      def path_params(base = Dry::Struct, &block)
        @path_params_class = make_struct!(base, &block)
        action_module.const_set('PathParams', @path_params_class)
      end

      ##
      # Define the body of the action method in the controller.
      def action(&body)
        return @action if body.nil?

        @action ||= body
      end

      def description(desc = nil)
        return @description if desc.nil?

        @description = desc
      end

      def summary(sum = nil)
        return @summary if sum.nil?

        @summary = sum
      end

      private

      def assign_action_module!
        @controller.send(:const_set, action_name.to_s.classify, action_module)
      end

      def make_struct!(base, &block)
        Class.new(base, &block).tap { |e| e.transform_keys(&:to_sym) if base == Dry::Struct }
      end

      def action_module
        @action_module ||= Module.new
      end

    end
  end
end
