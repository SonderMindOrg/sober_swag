# frozen_string_literal: true

require 'sober_swag/version'

##
# Root namespace
module SoberSwag
  class Error < StandardError; end

  autoload :Parser, 'sober_swag/parser'
  autoload :Nodes, 'sober_swag/nodes'
  autoload :Compiler, 'sober_swag/compiler'
end
