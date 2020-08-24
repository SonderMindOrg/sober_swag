module SoberSwag
  class OutputObject
    ##
    # Container to define a single output object.
    # This is the DSL used in the base of {SoberSwag::OutputObject.define}.
    class Definition
      def initialize
        @fields = []
        @views = []
      end

      attr_reader :fields, :views

      include FieldSyntax

      def add_field!(field)
        @fields << field
      end

      def view(name, &block)
        view = View.define(name, fields, &block)

        view.identifier("#{@identifier}.#{name.to_s.classify}") if identifier

        @views << view
      end

      def identifier(arg = nil)
        @identifier = arg if arg
        @identifier
      end
    end
  end
end
