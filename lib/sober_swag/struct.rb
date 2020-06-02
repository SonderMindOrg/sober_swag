module SoberSwag
  ##
  # A variant of Dry::Struct that allows you to set a "model name" that is publically visible.
  # If you do not set one, it will be the Ruby class name, with any '::' replaced with a '.'.
  #
  # This otherwise behaves exactly like a Dry::Struct.
  # Please see the documentation for that class to see how it works.
  class Struct < Dry::Struct

    class << self
      ##
      # The name to use for this type in external documentation.
      def sober_name(arg = nil)
        @sober_name = arg if arg
        @sober_name || self.name.gsub('::', '.')
      end
    end

  end
end
