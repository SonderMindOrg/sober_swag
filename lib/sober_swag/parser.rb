module SoberSwag
  ##
  # Parses a *Dry-Types Schema* into a set of nodes we can use to compile.
  # This is mostly because the vistior pattern sucks and catamorphisms are nice.
  #
  # Do not use this class directly, as it is not part of the public api.
  # Instead, use classes from the {SoberSwag::Compiler} namespace.
  class Parser
    def initialize(node)
      @node = node
      @found = Set.new
    end

    ##
    # Compile to one of our internal nodes.
    # @return [SoberSwag::Nodes::Base] the node that describes this type.
    def to_syntax # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      case @node
      when Dry::Types::Default
        # we handle this elsewhere, so
        bind(Parser.new(@node.type))
      when Dry::Types::Array::Member
        Nodes::List.new(bind(Parser.new(@node.member)))
      when Dry::Types::Enum
        Nodes::Enum.new(@node.values)
      when Dry::Types::Schema
        Nodes::Object.new(
          @node.map { |attr| bind(Parser.new(attr)) }
        )
      when Dry::Types::Schema::Key
        Nodes::Attribute.new(
          @node.name,
          @node.required? && !@node.type.default?,
          bind(Parser.new(@node.type)),
          @node.meta
        )
      when Dry::Types::Sum
        left = bind(Parser.new(@node.left))
        right = bind(Parser.new(@node.right))
        # special case booleans to just return the left value
        # this is because modeling a boolean as a sum type of
        # TrueClass and FalseClass is kinda weird, because they're
        # considered different types instead of different constructors,
        # which we don't want to do
        is_bool = [left, right].all? do |e|
          e.respond_to?(:value) && [TrueClass, FalseClass].include?(e.value)
        end
        if is_bool
          left
        else
          Nodes::Sum.new(left, right)
        end
      when Dry::Types::Constrained
        bind(Parser.new(@node.type))
      when Dry::Types::Nominal
        if @node.respond_to?(:type) && @node.type.is_a?(Dry::Types::Constrained)
          bind(Parser.new(@node.type))
        else
          old_meta = @node.primitive.respond_to?(:meta) ? @node.primitive.meta : {}
          # start off with the moral equivalent of NodeTree[String]
          Nodes::Primitive.new(@node.primitive, old_meta.merge(@node.meta))
        end
      else
        # Inside of this case we have a class that is some user-defined type
        # We put it in our array of found types, and consider it a primitive
        @found.add(@node)
        Nodes::Primitive.new(@node, @node.respond_to?(:meta) ? @node.meta : {})
      end
    end

    def run_parser
      [to_syntax, found]
    end

    ##
    # What other types did we find while parsing this type?
    attr_reader :found

    ##
    # Call `.to_syntax` on another node, putting any new classes it finds
    # in the list of classes we found in the process.
    #
    # If you're a big Haskell nerd, then this is >>=.
    def bind(other)
      result = other.to_syntax
      @found += other.found
      result
    end
  end
end
