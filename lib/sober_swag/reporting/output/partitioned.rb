module SoberSwag
  module Reporting
    module Output
      ##
      # Partition output into one of two possible cases.
      class Partitioned < Base
        ##
        # @param partition [#call] block that returns true or false for the input type
        # @param true_output [Interface] serializer to use if block is true
        # @param false_output [Interface] serializer to use if block is false
        def initialize(partition, true_output, false_output)
          @partition = partition
          @true_output = true_output
          @false_output = false_output
        end

        ##
        # @return [#call] partitioning block
        attr_reader :partition

        ##
        # @return [Interface]
        attr_reader :true_output

        ##
        # @return [Interface]
        attr_reader :false_output

        def call(item)
          serializer_for(item).call(item)
        end

        def serialize_report(item)
          serializer_for(item).serialize_report(item)
        end

        def swagger_schema
          true_schema, true_found = true_output.swagger_schema
          false_schema, false_found = false_output.swagger_schema

          [
            {
              oneOf: (true_schema[:oneOf] || [true_schema]) + (false_schema[:oneOf] || [false_schema])
            },
            true_found.merge(false_found)
          ]
        end

        private

        ##
        # @return [Interface]
        def serializer_for(item)
          if partition.call(item)
            true_output
          else
            false_output
          end
        end
      end
    end
  end
end
