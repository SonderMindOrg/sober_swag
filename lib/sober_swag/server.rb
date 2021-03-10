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
        begin
          "#{controller}_controller".classify.constantize
        rescue StandardError
          nil
        end
      }.compact.filter { |controller| controller.ancestors.include?(SoberSwag::Controller) }
    end

    ##
    # Start up.
    #
    # @param controller_proc [Proc] a proc that, when called, gives a list of {SoberSwag::Controller}s to document
    # @param cache [Bool | Proc] if we should cache our defintions (default false)
    # @param redoc_version [String] what version of the redoc library to use to display UI (default 'next', the latest version).
    def initialize(
      controller_proc: RAILS_CONTROLLER_PROC,
      cache: false,
      redoc_version: 'next'
    )
      @controller_proc = controller_proc
      @cache = cache
      @html = EFFECT_HTML.gsub(/REDOC_VERSION/, redoc_version)
    end

    EFFECT_HTML = <<~HTML.freeze
      <!DOCTYPE html>
      <html>
        <head>
          <title>ReDoc</title>
          <!-- needed for adaptive design -->
          <meta charset="utf-8"/>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">

          <!--
          ReDoc doesn't change outer page styles
          -->
          <style>
            body {
              margin: 0;
              padding: 0;
            }
          </style>
        </head>
        <body>
          <redoc spec-url='SCRIPT_NAME'></redoc>
          <script src="https://cdn.jsdelivr.net/npm/redoc@REDOC_VERSION/bundles/redoc.standalone.js"> </script>
        </body>
      </html>
    HTML

    def call(env)
      req = Rack::Request.new(env)
      if req.path_info&.match?(/json/si) || req.get_header('Accept')&.match?(/json/si)
        [200, { 'Content-Type' => 'application/json' }, [generate_json_string]]
      else
        [200, { 'Content-Type' => 'text/html' }, [@html.gsub(/SCRIPT_NAME/, "#{env['SCRIPT_NAME']}.json")]]
      end
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
