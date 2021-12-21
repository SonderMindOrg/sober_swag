module SoberSwag
  module Reporting
    module Report
      ##
      # Base class for SoberSwag reports.
      #
      # These reports are what make these serializers and parsers *reporting*: they provide errors.
      # For outputs, these are errors encountered during serialization, IE,
      # places where we lied about what type we were going to serialize.
      # This is mostly used for testing.
      #
      # For parsers, these are encountered during *parsing*.
      # This can be easily converted into a hash of JSON path objects to individual errors,
      # enabling developers to more easily see what's gone wrong.
      class Base
        ##
        # @return [Array<[String]>]
        #   An array of error paths and error components, in the form of:
        #
        #   ```ruby
        #     [
        #       'foo.bar: was bad',
        #       'foo.bar: was even worse'
        #     ]
        #   ```
        def full_errors
          each_error.map do |k, v|
            [k, v].reject(&:blank?).join(': ')
          end
        end

        ##
        # Get a hash where each key is a JSON path, and each value is an array of errors for that path.
        # @return [Hash<String,Array<String>>] hash of JSON path to errors
        def path_hash
          Hash.new { |h, k| h[k] = [] }.tap do |hash|
            each_error do |k, v|
              hash["$#{k}"] << v
            end
          end
        end

        ##
        # @overload each_error() { |path, val| nil }
        #   Yields each error to the block.
        #   @yield [path, val] the JSON path to the error, and an error string
        #   @yieldparam [String, String]
        # @overload each_error()
        #   @return [Enumerable<String, String>] an enum of two values: error keys and error values.
        #     Note: the same key can potentially occur more than once!
        def each_error
          return enum_for(:each_error) unless block_given?
        end
      end
    end
  end
end
