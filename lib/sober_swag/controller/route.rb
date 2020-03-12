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

      attr_reader :controller, :method, :path, :action_name, :body_class

      def body(&block)
        @body_class = Class.new(Dry::Struct, &block)
        @body_class.transform_keys(&:to_sym)
        action_module.const_set('Body', @body_class)
      end

      def action(&body)
        return @action if body.nil?

        @action ||= body
      end

      private

      def assign_action_module!
        @controller.send(:const_set, action_name.to_s.classify, action_module)
      end

      def action_module
        @action_module ||= Module.new
      end

    end
  end
end
