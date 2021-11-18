module SoberSwag
  module Reporting
    module Output
      ##
      # Apply a mapping function before calling
      # a base output.
      class ViaMap < Base
        def initialize(output, mapper)
          @output = output
          @mapper = mapper
        end

        ##
        # @return [Interface] base output
        attr_reader :output

        ##
        # @return [#call] mapping function
        attr_reader :mapper

        def call(input)
          output.call(mapper.call(input))
        end

        def serialize_report(input)
          output.serialize_report(mapper.call(input))
        end

        def view(view)
          ViaMap.new(output.view(view), mapper)
        end

        def views
          output.views
        end

        def swagger_schema
          output.swagger_schema
        end
      end
    end
  end
end
