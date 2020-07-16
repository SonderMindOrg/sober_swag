module SoberSwag
  ##
  # Parses a *Dry-Types Schema* into a set of nodes we can use to compile.
  # This is mostly because the vistior pattern sucks and catamorphisms are nice.
  class Parser
    def initialize(node)
      @node = node
      @found = Set.new
    end

    def to_syntax # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      case @node
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
          @node.required?,
          bind(Parser.new(@node.type))
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
        # start off with the moral equivalent of NodeTree[String]
        Nodes::Primitive.new(@node.primitive, @node.meta)
      else
        # Inside of this case we have a class that is some user-defined type
        # We put it in our array of found types, and consider it a primitive
        @found.add(@node)
        Nodes::Primitive.new(@node)
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
