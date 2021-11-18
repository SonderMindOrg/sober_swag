module SoberSwag
  module Reporting
    module Report
      ##
      # Base class, makes is_a? checks easier.
      class Base
        ##
        # @return [Array<[String,String]>]
        def full_errors
          each_error.map do |k, v|
            [k, v].reject(&:blank?).join(': ')
          end
        end

        ##
        # @return [Hash<String,String>] hash of JSON path to errors
        def path_hash
          Hash.new { |h, k| h[k] = [] }.tap do |hash|
            each_error do |k, v|
              hash["$#{k}"] << v
            end
          end
        end
      end
    end
  end
end
