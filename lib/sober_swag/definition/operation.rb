module SoberSwag
  module Definition
    ##
    # Define an API operation
    class Operation
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        query: nil,
        path: nil,
        body: nil,
        tags: [],
        description: nil,
        summary: nil
      )
        # rubocop:enable Metrics/ParameterLists
        @query = query
        @path = path
        @body = body
        @tags = tags
        @description = description
        @summary = summary
      end

      def each_type
        return enum_for(:each_type) unless block_given?

        yield body if body
      end
    end
  end
end
