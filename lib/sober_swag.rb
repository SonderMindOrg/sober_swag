# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'sober_swag/types'
require 'sober_swag/version'

##
# Root namespace
module SoberSwag
  class Error < StandardError; end

  autoload :Parser, 'sober_swag/parser'
  autoload :Nodes, 'sober_swag/nodes'
  autoload :Compiler, 'sober_swag/compiler'
  autoload :Controller, 'sober_swag/controller'
end
