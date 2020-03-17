module SoberSwag
  module Definition
    ##
    # Define all the stuff you can do on a single path
    class Path
      OPERATIONS = %i[get put post head delete].freeze

      OPERATIONS.each do |operation|
        attr_accessor operation
      end

      def each_type
        return enum_for(:each_type) unless block_given?

        OPERATIONS.each do |op|
          n = public_send(op)
          n&.each_type { |e| yield e }
        end
      end
    end
  end
end
