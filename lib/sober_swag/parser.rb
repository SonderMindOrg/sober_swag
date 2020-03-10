module SoberSwag
  class Parser
    def initialize(node)
      @node = node
      @found = Set.new
    end

    def to_syntax
      case @node
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
        Nodes::Sum.new(bind(Parser.new(@node.left)), bind(Parser.new(@node.right)))
      when Dry::Types::Constrained
        bind(Parser.new(@node.type))
      when Dry::Types::Nominal
        # start off with the moral equivalent of NodeTree[String]
        Nodes::Primitive.new(@node.primitive)
      else
        # Inside of this case we have a class that is some user-defined type sorta deal.
        # We put it in our array of found types, and consider it a primitive type
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
