require 'set'

module SoberSwag
  ##
  # A basic, rack-only server to serve up swagger definitions.
  # By default it is configured to work with rails, but you can pass stuff to initialize.
  class Server

    RAILS_CONTROLLER_PROC = proc do
      Rails.application.routes.routes.map { |route|
        route.defaults[:controller]
      }.to_set.reject(&:nil?).map { |controller|
        "#{controller}_controller".classify.constantize
      }.filter { |controller| controller.ancestors.include?(SoberSwag::Controller) }
    end

    ##
    # Start up.
    #
    # @param controller_proc [Proc] a proc that, when called, gives a list of {SoberSwag::Controller}s to document
    # @param cache [Bool | Proc] if we should cache our defintions (default false)
    def initialize(controller_proc: RAILS_CONTROLLER_PROC, cache: false)
      @controller_proc = controller_proc
      @cache = cache
    end

    def call(*)
      [200, { 'Content-Type' => 'application/json' }, [generate_json_string]]
    end

    def generate_json_string
      if cache?
        @json_string ||= JSON.dump(generate_swagger)
      else
        JSON.dump(generate_swagger)
      end
    end

    def cache?
      @cache.respond_to?(:call) ? @cache.call : @cache
    end

    def generate_swagger
      routes = sober_controllers.flat_map(&:defined_routes).reduce(SoberSwag::Compiler.new) { |c, r| c.add_route(r) }
      {
        openapi: '3.0.0',
        info: {
          version: '1',
          title: 'SoberSwag Swagger'
        }
      }.merge(routes.to_swagger)
    end

    def sober_controllers
      @controller_proc.call
    end

  end
end
