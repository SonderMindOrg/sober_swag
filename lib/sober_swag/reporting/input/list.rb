module SoberSwag
  module Reporting
    module Input
      ##
      # Class to parse an array, where each element has the same type.
      #
      # Called List to avoid name conflicts.
      class List < Base
        ##
        # @see #new
        def self.of(element)
          initialize(element)
        end

        ##
        # @param element [Base] the parser for elements
        def initialize(element)
          @element = element
        end

        ##
        # @return [Base] the parser for elements
        attr_reader :element

        def call(value)
          return Report::Value.new(['was not an array']) unless value.is_a?(Array)

          # obtain a hash of indexes => errors
          errs = {}
          # yes, side effects in a map are evil, but we avoid traversal twice
          mapped = value.map.with_index do |item, idx|
            element.call(item).tap { |e| errs[idx] = e if e.is_a?(Report::Base) }
          end

          if errs.any?
            Report::List.new(errs)
          else
            mapped
          end
        end

        def swagger_schema
          schema, found = element.swagger_schema

          [{ type: 'list', items: schema }, found]
        end
      end
    end
  end
end
