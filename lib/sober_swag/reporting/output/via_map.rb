module SoberSwag
  module Reporting
    module Output
      ##
      # Apply a mapping function before calling
      # a base output.
      #
      # Note that this is applied *before* the base output.
      # This is different than {SoberSwag::Reporting::Input::Mapped}, which does the reverse.
      # IE, this class does `call block -> pass result to base output`,
      # while the other does `call serializer -> pass result to block`.
      #
      # If you want to get *really* nerdy, this is *contravariant* to `Mapped`.
      #
      # This lets you do things like making an output that serializes to strings via `to_s`:
      #
      # ```ruby
      # ToSTextOutput = SoberSwag::Reporting::Output::ViaMap.new(
      #   SoberSwag::Reporting::Output.text,
      #   proc { |arg| arg.to_s }
      # )
      #
      # class Person
      #   def to_s
      #     'Person'
      #   end
      # end
      #
      # ToSTextOutput.call(Person.new) # => 'Person'
      # ```
      class ViaMap < Base
        def initialize(output, mapper)
          @output = output
          @mapper = mapper
        end

        ##
        # @return [Interface] base output
        attr_reader :output

        ##
        # @return [#call] mapping function
        attr_reader :mapper

        def call(input)
          output.call(mapper.call(input))
        end

        def serialize_report(input)
          output.serialize_report(mapper.call(input))
        end

        def view(view)
          ViaMap.new(output.view(view), mapper)
        end

        def views
          output.views
        end

        def swagger_schema
          output.swagger_schema
        end
      end
    end
  end
end
