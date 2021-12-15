module SoberSwag
  module Reporting
    module Output
      ##
      # Defer loading of an output for mutual recursion and/or loading time speed.
      # Probably just do this for mutual recursion though.
      #
      # Note: this *does not* save you from infinite schema generation.
      # This type *must* return some sort of {Referenced} type in order to do that!
      #
      # The common use case for this is mutual recursion.
      # Something like...
      #
      # ```ruby
      # class PersonOutput < SoberSwag::Reporting::Output::Struct
      #   field :first_name, SoberSwag::Reporting::Output.text
      #   view :detail do
      #     field :classes, SoberSwag::Reporting::Output::Defer.new { ClassroomOutput.view(:base).array }
      #   end
      # end
      #
      # class ClassroomOutut < SoberSwag::Reporting::Output::Struct
      #   field :class_name, SoberSwag::Reporting::Output.text
      #
      #   view :detail do
      #     field :students, SoberSwag::Reporting::Output::Defer.new { PersonOutput.view(:base).array }
      #   end
      # end
      # ```
      class Defer < Base
        ##
        # Nicer initialization: uses a block.
        #
        # @yieldreturn [Interface] serializer to use.
        def self.defer(&block)
          new(block)
        end

        def initialize(other_lazy)
          @other_lazy = other_lazy
        end

        attr_reader :other_lazy

        ##
        # @return [Interface]
        def other
          @other ||= other_lazy.call
        end

        def call(input)
          other.call(input)
        end

        def serialize_report(input)
          other.serialize_report(input)
        end

        def view(view)
          other.view(view)
        end

        def swagger_schema
          other.swagger_schema
        end
      end
    end
  end
end
