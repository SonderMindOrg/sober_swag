require 'active_support/concern'

module SoberSwag
  ##
  # This module can be included in any subclass of `ActionController` or `ActionController::API` to make it `SoberSwag`-able.
  # This means that you can use the mechanics of SoberSwag to define a type-safe API, with generated Swagger documentation!
  module Controller
    extend ActiveSupport::Concern

    autoload :UndefinedBodyError, 'sober_swag/controller/undefined_body_error'
    autoload :UndefinedPathError, 'sober_swag/controller/undefined_path_error'
    autoload :UndefinedQueryError, 'sober_swag/controller/undefined_query_error'

    ##
    # Types module, so you can more easily access Types::Whatever
    # without having to type SoberSwag::Types::Whatever.
    module Types
      include ::Dry::Types()
    end

    ##
    # Module containing class methods.
    # Any class that `include`s {SoberSwag::Controller} will also `extend` {SoberSwag::Controller::ClassMethods}.
    module ClassMethods
      ##
      # Define a new action with the given HTTP method, action name, and path.
      # This will eventually delegate to making an actual method on your controller,
      # so you can use controllers as you wish with no harm.
      #
      # This method takes a block, evaluated in the context of a {SoberSwag::Controller::Route}.
      # Used like:
      #
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
      # This will define an "action module" on this class to contain the generated types.
      # In the above example, the following constants will be defined on the controller:
      #
      # - `PostsController::Show` - the container module for everything in this action
      # - `PostsController::Show::PathParams` - the dry-struct type for the path attribute.
      #
      # So, in the same controller, you can refer to Show::PathParams to get the type created by the 'path_params' block above.
      #
      # The block given evaluates in the context of `SoberSwag::Controller::Route`.
      #
      # @todo Explore parsing the `path` parameter from rails routes so we can avoid forcing the duplicate boilerplate.
      #
      # @param method [Symbol] the HTTP method of this route
      # @param action [Symbol] the name of the controller method this maps onto
      # @param path [String] an OpenAPI v3 Path Specifier
      def define(method, action, path, &block)
        r = Route.new(method, action, path)
        r.instance_eval(&block)
        const_set(r.action_module_name, r.action_module)
        defined_routes << r
      end

      ##
      # All the routes that this controller knows about.
      # @return [Array<SoberSwag::Controller::Route>
      def defined_routes
        @defined_routes ||= []
      end

      ##
      # Find a route with the given name.
      # @param name [Symbol] the name
      # @return [SoberSwag::Controller::Route]
      def find_route(name)
        defined_routes.find { |r| r.action_name.to_s == name.to_s }
      end

      ##
      # Get the OpenAPI v3 definition for this controller.
      #
      # @return [Hash]
      def swagger_info
        @swagger_info ||=
          begin
            res = defined_routes.reduce(SoberSwag::Compiler.new) { |c, r| c.add_route(r) }
            {
              openapi: '3.0.0',
              info: { version: '1', title: name }
            }.merge(res.to_swagger)
          end
      end
    end

    included do |base|
      base.extend ClassMethods
    end

    ##
    # ActiveController action to get the swagger definition for this API.
    # It renders a JSON of the OpenAPI v3 schema for this API.
    def swagger
      render json: self.class.swagger_info
    end

    ##
    # Get the path parameters, parsed into the type you defined with {SoberSwag::Controller.define}
    # @raise [UndefinedPathError] if there's no path params defined for this route
    # @raise [Dry::Struct::Error] if we cannot convert the path params to the defined type.
    def parsed_path
      @parsed_path ||=
        begin
          r = current_action_def
          raise UndefinedPathError unless r&.path_params_class

          r.path_params_class.call(request.path_parameters)
        end
    end

    ##
    # Get the request body, parsed into the type you defined with {SoberSwag::Controller.define}.
    # @raise [UndefinedBodyError] if there's no request body defined for this route
    # @raise [Dry::Struct::Error] if we cannot convert the path params to the defined type.
    def parsed_body
      @parsed_body ||=
        begin
          r = current_action_def
          raise UndefinedBodyError unless r&.request_body_class

          r.request_body_class.call(body_params)
        end
    end

    ##
    # Get the query params, parsed into the type you defined with {SoberSwag::Controller.define}
    # @raise [UndefinedQueryError] if there's no query params defined for this route
    # @raise [Dry::Struct::Error] if we cannot convert the path params to the defined type.
    def parsed_query
      @parsed_query ||=
        begin
          r = current_action_def
          raise UndefinedQueryError unless r&.query_params_class

          r.query_params_class.call(request.query_parameters)
        end
    end

    ##
    # Respond with the serialized type that you defined for this route.
    # @todo figure out how to specify views and other options for the serializer here
    # @param status [Symbol] the HTTP status symbol to use for the status code
    # @param entity the thing to serialize
    def respond!(status, entity, serializer_opts: {}, rails_opts: {})
      r = current_action_def
      serializer = r.response_serializers[Rack::Utils.status_code(status)]
      serializer ||= serializer.new if serializer.respond_to?(:new)
      render json: serializer.serialize(entity, serializer_opts), status: status, **rails_opts
    end

    ##
    # Obtain a parameters hash of *only* those parameters which come in the hash.
    # These will be *unsafe* in the sense that they will all be allowed.
    # This kinda violates the "be liberal in what you accept" principle,
    # but it keeps the docs honest: parameters sent in the body *must* be
    # in the body.
    #
    # @return [Hash]
    def body_params
      request.request_parameters
    end

    ##
    # Get the action-definition for the current action.
    # Under the hood, delegates to the `:action` key of rails params.
    # @return [SoberSwag::Controller::Route]
    def current_action_def
      self.class.find_route(params[:action])
    end
  end
end

require 'sober_swag/controller/route'
