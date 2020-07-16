module SoberSwag
  class Blueprint
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
        @views << View.define(name, fields, &block)
      end

      def identifier(arg = nil)
        @identifier = arg if arg
        @identifier
      end

    end
  end
end
