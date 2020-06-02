# frozen_string_literal: true

require 'bundler'
Bundler.setup
require 'dry-struct'
require 'dry-types'
require 'sober_swag/types'
require 'sober_swag/version'
require 'active_support/inflector'

##
# Root namespace
module SoberSwag
  class Error < StandardError; end

  autoload :Parser, 'sober_swag/parser'
  autoload :Serializer, 'sober_swag/serializer'
  autoload :Blueprint, 'sober_swag/blueprint'
  autoload :Nodes, 'sober_swag/nodes'
  autoload :Compiler, 'sober_swag/compiler'
  autoload :Controller, 'sober_swag/controller'
  autoload :Struct, 'sober_swag/struct'

  ##
  # Define a struct of something.
  # Useful to prevent weirdness from autoloading.
  # @param parent [Class] the base class for the struct (default of {SoberSwag::Struct})
  def self.struct(parent = nil, &block)
    Class.new(parent || SoberSwag::Struct, &block)
  end
end
