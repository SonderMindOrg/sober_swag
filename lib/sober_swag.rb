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
  autoload :InputObject, 'sober_swag/input_object'
  autoload :Server, 'sober_swag/server'

  ##
  # Define a struct of something.
  # Useful to prevent weirdness from autoloading.
  # @param parent [Class] the base class for the struct (default of {SoberSwag::Struct})
  def self.input_object(parent = nil, &block)
    Class.new(parent || SoberSwag::InputObject, &block)
  end
end
