# frozen_string_literal: true

require 'bundler'
Bundler.setup
require 'dry-struct'
require 'dry-types'
require 'action_controller'
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
  autoload :Serializer, 'sober_swag/serializer'
end
