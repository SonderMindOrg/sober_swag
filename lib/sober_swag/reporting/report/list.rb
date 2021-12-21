module SoberSwag
  module Reporting
    module Report
      ##
      # Report errors that arose while parsing a list.
      class List < Base
        ##
        # @param element [Hash<Int, Base>] a hash of bad element indices to bad
        #   element values
        def initialize(elements)
          @elements = elements
        end

        attr_reader :elements

        def each_error
          return enum_for(:each_error) unless block_given?

          elements.each do |k, v|
            v.each_error do |nested, err|
              yield ["[#{k}]", nested].reject(&:nil?).join(''), err
            end
          end
        end
      end
    end
  end
end
