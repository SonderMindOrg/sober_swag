module SoberSwag
  module Reporting
    module Output
      ##
      # Interface methods for all outputs.
      module Interface
        def call!(item)
          res = serialize_report(item)

          raise Report::Error.new(res) if res.is_a?(Report::Base) # rubocop:disable Style/RaiseArgs

          res
        end

        ##
        # Show off that this is a reporting output.
        def reporting?
          true
        end

        ##
        # Delegates to {#call}
        def serialize(item)
          call(item)
        end

        def via_map(&block)
          raise ArgumentError, 'block argument required' unless block

          ViaMap.new(self, block)
        end

        ##
        # @return [SoberSwag::Reporting::Output::Enum]
        def enum(*cases)
          Enum.new(self, cases)
        end

        def referenced(name)
          Referenced.new(self, name)
        end

        ##
        # @return [SoberSwag::Reporting::Output::InRange]
        # Constrained values: must be within the given range.
        def in_range(range)
          raise ArgumentError, 'need a range' unless range.is_a?(Range)

          InRange.new(self, range)
        end

        def list
          List.new(self)
        end

        alias array list

        ##
        # Partition this serializer into two potentials.
        # If the block given returns *false*, we will use `other` as the serializer.
        # Otherwise, we will use `self`.
        #
        # This might be useful to serialize a sum type:
        #
        # ```ruby
        # ResolutionOutput = TransferOutput.partitioned(RefundOutput) { |to_serialize| to_serialize.is_a?(Transfer)
        # ```
        #
        # @param other [Interface] serializer to use if the block returns false
        # @yieldreturn [true,false] false if we should use the other serializer
        # @return [Interface]
        def partitioned(other, &block)
          raise ArgumentError, 'need a block' if block.nil?

          Partitioned.new(
            block,
            self,
            other
          )
        end

        def nilable
          Partitioned.new(
            :nil?.to_proc,
            Null.new,
            self
          )
        end

        def described(description)
          Described.new(self, description)
        end
      end
    end
  end
end
