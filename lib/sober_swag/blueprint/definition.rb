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

      def sober_name(arg = nil)
        @sober_name = arg if arg
        @sober_name
      end

    end
  end
end
