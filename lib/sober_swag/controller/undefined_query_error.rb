module SoberSwag
  module Controller
    ##
    # Error class thrown if you have no query defined,
    # but try to call `parsed_query`.
    class UndefinedQueryError < Error
    end
  end
end
