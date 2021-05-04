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

      ##
      # @return [Array<SoberSwag::OutputObject::Field>]
      attr_reader :fields

      ##
      # @return [Array<SoberSwag::OutputObject::View>]
      attr_reader :views

      include FieldSyntax

      ##
      # Adds a new field to the fields array
      # @param field [SoberSwag::OutputObject::Field]
      def add_field!(field)
        @fields << field
      end

      ##
      # Define a new view, with the view DSL
      # @param name [Symbol] the name of the view
      # @param inherits [Symbol] the name of another view this
      #   view will "inherit" from
      # @yieldself [SoberSwag::OutputObject::View]
      # @return [nil] nothing interesting.
      def view(name, inherits: nil, &block)
        initial_fields =
          if inherits.nil? || inherits == :base
            fields
          else
            find_view(inherits).fields
          end
        view = View.define(name, initial_fields, &block)

        view.identifier("#{@identifier}.#{name.to_s.classify}") if identifier

        @views << view
      end

      ##
      # @overload identifier()
      #   Get the identifier of this output object.
      #   @return [String] the identifier
      # @overload identifier(arg)
      #   Set the identifier of this output object.
      #   @param arg [String] the external identifier to use for this OutputObject
      #   @return [String] `arg`
      def identifier(arg = nil)
        @identifier = arg if arg
        @identifier
      end

      private

      ##
      # Get the already-defined view with a specific name.
      #
      # @param name [Symbol] name of view to look up
      # @return [SoberSwag::OutputObject::View] the view found
      # @raise [ArgumentError] if no view with that name found
      def find_view(name)
        @views.find { |view| view.name == name } || (raise ArgumentError, "no view #{name.inspect} defined!")
      end
    end
  end
end
