# frozen_string_literal: true

require 'bundler'
Bundler.setup
require 'dry-struct'
require 'dry-types'
require 'sober_swag/types'
require 'sober_swag/version'
require 'active_support/inflector'

##
# Root namespace for the SoberSwag Module.
module SoberSwag
  ##
  # Root Error Class for SoberSwag errors.
  class Error < StandardError; end

  autoload :Parser, 'sober_swag/parser'
  autoload :Serializer, 'sober_swag/serializer'
  autoload :OutputObject, 'sober_swag/output_object'
  autoload :Nodes, 'sober_swag/nodes'
  autoload :Compiler, 'sober_swag/compiler'
  autoload :Controller, 'sober_swag/controller'
  autoload :InputObject, 'sober_swag/input_object'
  autoload :Server, 'sober_swag/server'
  autoload :Type, 'sober_swag/type'
  autoload :Reporting, 'sober_swag/reporting'

  ##
  # Define a struct of something.
  # Useful to prevent weirdness from autoloading.
  #
  # @param parent [Class] the base class for the struct (default of {SoberSwag::Struct})
  # @yieldself [SoberSwag::InputObject]
  # @return [Class] the input object class generated
  def self.input_object(parent = nil, &block)
    Class.new(parent || SoberSwag::InputObject, &block)
  end
end
