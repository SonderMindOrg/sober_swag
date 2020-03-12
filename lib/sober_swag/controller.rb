module SoberSwag
  class Controller < ActionController::API

    autoload :Route, 'sober_swag/controller/route'
    autoload :UndefinedBodyError, 'sober_swag/controller/undefined_body_error'

    module Types
      include ::Dry::Types()
    end

    class << self
      def define(method, action, path, &block)
        r = Route.new(self, method, action, path)
        r.instance_eval(&block)
        defined_routes << r
        define_method(action, r.action)
      end

      def defined_routes
        @defined_routes ||= []
      end

      def find_route(name)
        defined_routes.find { |r| r.action_name.to_s == name.to_s }
      end
    end


    def parsed_body
      @parsed_body ||=
        begin
          r = self.class.find_route(params[:action])
          raise UndefinedBodyError unless r&.body_class
          r.body_class.new(body_params)
        end
    end

    ##
    # Only the params that came in the request body.
    # This kinda violates the "be liberal in what you accept" principle,
    # but it keeps the docs honest: parameters sent in the body *must* be
    # in the body.
    def body_params
      bparams = params.reject do |k, _|
        request.query_parameters.key?(k) || request.path_parameters.key?(k)
      end
      bparams.permit(bparams.keys)
    end
  end
end
