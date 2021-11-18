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

        def via_map(&block)
          raise ArgumentError, 'block argument required' unless block

          ViaMap.new(self, block)
        end

        def referenced(name)
          Referenced.new(self, name)
        end

        def list
          List.new(self)
        end

        def array
          List.new(self)
        end

        def described(description)
          Described.new(self, description)
        end
      end
    end
  end
end
