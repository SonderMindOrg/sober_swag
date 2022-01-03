module SoberSwag
  module Reporting
    module Input
      ##
      # Module for interface methods.
      module Interface
        ##
        # Make a new input that is either this type or the argument.
        #
        # @argument other [Interface] other input type
        # @return [Either] this input, or some other input.
        def or(other)
          Either.new(self, other)
        end

        ##
        # @see {#or}
        def |(other)
          Either.new(self, other)
        end

        ##
        # This, or null.
        #
        # @return [Either] an either type of this or nil.
        def optional
          self | Null.new
        end

        ##
        # A list of this input.
        #
        # @return [List] the new input.
        def list
          List.new(self)
        end

        ##
        # Constrained values: must be in range.
        # @return [InRange]
        def in_range(range)
          raise ArgumentError, "need a range, not a #{range.class}" unless range.is_a?(Range)

          InRange.new(self, range)
        end

        ##
        # Constrained values: must be a multiple of the given number
        def multiple_of(number)
          MultipleOf.new(self, number)
        end

        def referenced(name)
          Referenced.new(self, name)
        end

        def format(format)
          Format.new(self, format)
        end

        def described(desc)
          Described.new(self, desc)
        end

        def enum(*cases)
          Enum.new(self, cases)
        end

        ##
        # Map a function after this input runs.
        #
        # @return [Mapped] the new input.
        def mapped(&block)
          Mapped.new(self, block)
        end

        def call!(value)
          res = call(value)
          raise Report::Error.new(res) if res.is_a?(Report::Base) # rubocop:disable Style/RaiseArgs

          res
        end

        def swagger_path_schema
          raise InvalidSchemaError::InvalidForPathError.new(self) # rubocop:disable Style/RaiseArgs
        end

        def swagger_query_schema
          raise InvalidSchemaError::InvalidForQueryError.new(self) # rubocop:disable Style/RaiseArgs
        end

        def modify_schema(base, addition)
          schema, found = base.swagger_schema
          merged =
            if schema.key?(:$ref)
              { allOf: [schema] }
            else
              schema
            end.merge(addition)
          [merged, found]
        end

        def add_schema_key(base, addition)
          if base.key?(:$ref)
            { allOf: [base] }.merge(addition)
          else
            base.merge(addition)
          end
        end
      end
    end
  end
end
