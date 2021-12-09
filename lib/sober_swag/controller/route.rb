module SoberSwag
  module Controller
    ##
    # Describe a single controller endpoint.
    class Route # rubocop:disable Metrics/ClassLength
      ##
      # @param method [Symbol] the HTTP method to get
      # @param action_name [Symbol] the name of the rails action
      #   (the name of the controller method, usually)
      # @param path [String] an OpenAPI V3 path template,
      #   which should [match this format](https://swagger.io/docs/specification/describing-parameters/#path-parameters)
      def initialize(method, action_name, path)
        @method = method
        @path = path
        @action_name = action_name
        @response_serializers = {}
        @response_descriptions = {}
        @tags = []
      end

      ##
      # A hash of response code -> response serializer
      # @return [Hash{Symbol => SoberSwag::Serializer::Base}]
      #   response code to response serializer
      attr_reader :response_serializers

      ##
      # A hash of response code -> response description
      # @return [Hash{Symbol => String}]
      #   response code to response description
      attr_reader :response_descriptions

      ##
      # The HTTP method of this route.
      # @return [Symbol]
      attr_reader :method

      ##
      # The swagger path specifier of this route.
      # @return [String]
      attr_reader :path

      ##
      # The name of the rails action (usually the controller method) of this route.
      # @return [Symbol]
      attr_reader :action_name

      ##
      # What to parse the request body into.
      # @return [Class] a swagger-able class type for a request body.
      attr_reader :request_body_class
      ##
      # What to parse the request query_params into.
      # @return [Class] a swagger-able class type for query parameters.
      attr_reader :query_params_class
      ##
      # What to parse the path params into.
      # @return [Class] a swagger-able class type for path parameters.
      attr_reader :path_params_class

      ##
      # Standard swagger tags.
      #
      # @overload tags()
      #   Get the tags for this route.
      #   @return [Array<String,Symbol>] the tags.
      # @overload tags(*args)
      #   Set the tags for this route.
      #   @param tags [Array<String,Symbol>] the tags to set
      #   @return [Array<String,Symbol>] the tags used
      def tags(*args)
        return @tags if args.empty?

        @tags = args.flatten
      end

      ##
      # Define the request body, using SoberSwag's type-definition scheme.
      # The block passed will be used to define the body of a new subclass of `base` (defaulted to {SoberSwag::InputObject}.)
      # @overload request_body(base)
      #   Give a Swagger-able type that will be used to parse the request body, and used in generated docs.
      #   @param base [Class] a swagger-able class
      # @overload request_body(base = SoberSwag::InputObject, &block)
      #   Define a Swagger-able type inline to use to parse the request body.
      #   @see SoberSwag.input_object
      # @overload request_body(base = SoberSwag::Reporting::Input::Struct, reporting: true, &block)
      #   Define a swagger-able type inline, using the new reporting system.
      #   @see SoberSwag::Reporting::Input::Struct
      def request_body(base = SoberSwag::InputObject, reporting: false, &block)
        @request_body_class = make_input_object!(base, reporting: reporting, &block)
        action_module.const_set('RequestBody', @request_body_class)
      end

      ##
      # Does this route have a body defined?
      def request_body?
        !request_body_class.nil?
      end

      ##
      # @overload query_params(base)
      #   Give a Swagger-able type that will be used to parse the query params, and used in generated docs.
      #   @param base [Class] a swagger-able class
      # @overload query_params(base = SoberSwag::InputObject, &block)
      #   Define a Swagger-able type inline to use to parse the query params.
      #   @see SoberSwag.input_object
      # @overload query_params(base = SoberSwag::Reporting::Input::Struct, reporting: true, &block)
      #   Define a swagger-able type inline, using the new reporting system.
      #   @see SoberSwag::Reporting::Input::Struct
      def query_params(base = SoberSwag::InputObject, reporting: false, &block)
        @query_params_class = make_input_object!(base, reporting: reporting, &block)
        action_module.const_set('QueryParams', @query_params_class)
      end

      ##
      # Does this route have query params defined?
      def query_params?
        !query_params_class.nil?
      end

      ##
      # @overload path_params(base)
      #   Give a Swagger-able type that will be used to parse the path params, and used in generated docs.
      #   @param base [Class] a swagger-able class
      # @overload path_params(base = SoberSwag::InputObject, &block)
      #   Define a Swagger-able type inline to use to parse the path params.
      #   @see SoberSwag.input_object
      # @overload path_params(base = SoberSwag::Reporting::Input::Struct, reporting: true, &block)
      #   Define a swagger-able type inline, using the new reporting system.
      #   @see SoberSwag::Reporting::Input::Struct
      def path_params(base = SoberSwag::InputObject, reporting: false, &block)
        @path_params_class = make_input_object!(base, reporting: reporting, &block)
        action_module.const_set('PathParams', @path_params_class)
      end

      ##
      # Does this route have path params defined?
      def path_params?
        !path_params_class.nil?
      end

      ##
      # @overload description()
      #   Get a description of this route object.
      #   @return [String] markdown-formatted description
      # @overload description(desc)
      #   Set the description of this route object.
      #   @param desc [String] markdown-formatted description
      #   @return [String] `desc`.
      def description(desc = nil)
        return @description if desc.nil?

        @description = desc
      end

      ##
      # @overload summary()
      #   Get the summary of this route object, a short string that identifies
      #   what it does.
      #   @return [String] markdown-formatted summary
      # @overload summary(sum)
      #   Set a short, markdown-formatted summary of what this route does.
      #   @param sum [String] markdown-formatted summary
      def summary(sum = nil)
        return @summary if sum.nil?

        @summary = sum
      end

      ##
      # The container module for all the constants this will eventually define.
      # Each class generated by this Route will be defined within this module.
      # @return [Module] the module under which constants will be defined.
      def action_module
        @action_module ||= Module.new
      end

      ##
      # @overload response(status_code, description, &block)
      #   Define a new response from this route, by defining a serializer inline.
      #   This serializer will be defined as if with {SoberSwag::OutputObject.define}
      #
      #   Generally, you want to define your serializers elsewhere for independent testing and such.
      #   However, if you have a really quick thing to serialize, this works.
      #   @param status_code [Symbol]
      #     the name of the HTTP status of this response.
      #   @param description [String]
      #     a description of what this response is, markdown-formatted
      #   @param block [Proc]
      #     passed to {SoberSwag::OutputObject.define}
      #
      # @overload response(status_code, description, serializer)
      #   Define a new response from this route, with an existing serializer.
      #   The generated swagger will document this response's format using the serializer.
      #
      #   @param status_code [Symbol]
      #     the name of the HTTP status of this response
      #   @param description [String]
      #     a description of what this response is, markdown-formatted
      #   @param serializer [SoberSwag::Serializer::Base] a serializer to use for the
      #     body of this response
      def response(status_code, description, serializer = nil, &block)
        status_key = Rack::Utils.status_code(status_code)

        raise ArgumentError, 'Response defined!' if @response_serializers.key?(status_key)

        serializer ||= SoberSwag::OutputObject.define(&block)
        response_module.const_set(status_code.to_s.classify, serializer)
        @response_serializers[status_key] = serializer
        @response_descriptions[status_key] = description
      end

      ##
      # What you should call the module of this action in your controller.
      # @return [String]
      def action_module_name
        action_name.to_s.classify
      end

      private

      def response_module
        @response_module ||= Module.new.tap { |m| action_module.const_set(:Response, m) }
      end

      def make_input_object!(base, reporting:, &block)
        if reporting
          make_reporting_input!(
            base == SoberSwag::InputObject ? SoberSwag::Reporting::Input::Struct : base,
            &block
          )
        else
          make_non_reporting_input!(base, &block)
        end
      end

      def make_reporting_input!(base, &block)
        if block
          raise ArgumentError, 'non-class passed along with block' unless base.is_a?(Class)

          make_reporting_input_struct!(base, &block)
        else
          base
        end
      end

      def make_reporting_input_struct!(base, &block)
        raise ArgumentError, 'base class must be a soberswag reporting class!' unless base <= SoberSwag::Reporting::Input::Struct

        Class.new(base, &block)
      end

      def make_non_reporting_input!(base, &block)
        if base.is_a?(Class)
          make_input_class(base, block)
        elsif block
          raise ArgumentError, 'passed a non-class base and a block to an input'
        else
          base
        end
      end

      def make_input_class(base, block)
        if block
          Class.new(base, &block).tap do |e|
            e.transform_keys(&:to_sym) if [SoberSwag::InputObject, Dry::Struct].include?(base)
          end
        else
          base
        end
      end
    end
  end
end
