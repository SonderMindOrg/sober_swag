module SoberSwag
  module Controller
    ##
    # Error class thrown if you have no body defined,
    # but try to call `parsed_body`.
    class UndefinedBodyError < Error
    end
  end
end
