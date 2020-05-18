module SoberSwag
  class Controller < ActionController::API

    autoload :UndefinedBodyError, 'sober_swag/controller/undefined_body_error'
    autoload :UndefinedPathError, 'sober_swag/controller/undefined_path_error'
    autoload :UndefinedQueryError, 'sober_swag/controller/undefined_query_error'

    module Types
      include ::Dry::Types()
    end

    class << self
      ##
      # Define a new action with the given HTTP method, action name, and path.
      # This will eventaully delegate to making an actual method on your controller,
      # so you can use controllers as you wish with no harm.
      #
      # This method takes a block, evaluated in the context of a {SoberSwag::Controller::Route}.
      # Used like:
      #     define(:get, :show, '/posts/{id}') do
      #       path_params do
      #         attribute :id, Types::Integer
      #       end
      #       action do
      #         @post = Post.find(parsed_path.id)
      #         render json: @post
      #       end
      #     end
      #
      # This will define an "aciton module" on this class to contain the generated types.
      # So, in the same controller, you can refer to Show::PathParams to get the type created by the 'path_params' block above.
      def define(method, action, path, &block)
        r = Route.new(method, action, path)
        r.instance_eval(&block)
        const_set(r.action_module_name, r.action_module)
        defined_routes << r
        define_method(action, r.action)
      end

      ##
      # All the routes that this controller knows about.
      def defined_routes
        @defined_routes ||= []
      end

      ##
      # Find a route with the given name.
      def find_route(name)
        defined_routes.find { |r| r.action_name.to_s == name.to_s }
      end
    end

    ##
    # Get the path parameters, parsed into the type you defined with {SoberSwag::Controller.define}
    def parsed_path
      @parsed_query ||=
        begin
          r = current_action_def
          raise UndefinedPathError unless r&.path_params_class
          r.path_params_class.new(request.path_parameters)
        end
    end

    ##
    # Get the request body, parsed into the type you defined with {SoberSwag::Controller.define}.
    # If the request body cannot be parsed into that struct, this will throw an error.
    def parsed_body
      @parsed_body ||=
        begin
          r = current_action_def
          raise UndefinedBodyError unless r&.body_class
          r.body_class.new(body_params)
        end
    end

    def parsed_query
      @parsed_body ||=
        begin
          r = current_action_def
          raise UndefinedQueryError unless r&.query_class
          r.query_class.new(request.query_parameters)
        end
    end

    def respond!(status, entity)
      r = current_action_def
      serializer = r.response_serializers[Rack::Utils.status_code(status)]
      serializer ||= serializer.new if serializer.respond_to?(:new)
      render json: serializer.serialize(entity)
    end

    ##
    # Obtain a parameters hash of *only* those parameters which come in the hash.
    # These will be *unsafe* in the sense that they will all be allowed.
    # This kinda violates the "be liberal in what you accept" principle,
    # but it keeps the docs honest: parameters sent in the body *must* be
    # in the body.
    def body_params
      bparams = params.reject do |k, _|
        request.query_parameters.key?(k) || request.path_parameters.key?(k)
      end
      bparams.permit(bparams.keys)
    end

    def current_action_def
      self.class.find_route(params[:action])
    end

  end
end

require 'sober_swag/controller/route'
