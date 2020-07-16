module SoberSwag
  module Controller
    ##
    # Error class thrown if you have no path defined,
    # but try to call `parse_path`.
    class UndefinedPathError < Error
    end
  end
end
