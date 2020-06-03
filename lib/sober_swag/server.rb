require 'set'

module SoberSwag
  ##
  # A server that will give swagger for an entire rails application
  class Server

    def call(*)
      [200, { 'Content-Type' => 'application/json' }, [generate_json_string]]
    end

    def generate_json_string
      JSON.dump(generate_swagger)
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
      return [] unless defined?(Rails)

      Rails.application.routes.routes.map { |route|
        route.defaults[:controller]
      }.to_set.reject(&:nil?).map { |controller|
        "#{controller}_controller".classify.constantize
      }.filter { |controller| controller.ancestors.include?(SoberSwag::Controller) }
    end

  end
end
