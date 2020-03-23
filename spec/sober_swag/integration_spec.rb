require 'spec_helper'

RSpec.describe 'compilation integration round-tripping' do
  module Types
    include Dry::Types()
  end

  def self.define_spec_class(&block)
    let(:example_class) { Class.new(Dry::Struct, &block) }
    subject { compile_def(example_class) }
  end

  def self.result(arg)
    it { should eq(arg) }
  end

  def compile_def(klass)
    SoberSwag::Compiler.new.add_type(klass).schema_for(klass)
  end

  context 'with a basic as hell case' do
    define_spec_class do
      attribute :foo, Types::String
    end

    result(
      properties: {
        foo: {
          required: true,
          type: 'string'
        }
      },
      type: :object
    )
  end

  context 'with a case involving optional attributes' do
    define_spec_class do
      attribute? :foo, Types::String
    end

    result(
      properties: {
        foo: { type: 'string' }
      },
      type: :object
    )
  end

  context 'with a case involving sum types' do
    define_spec_class do
      attribute :foo, Types::String | Types::Integer
    end
    result(
      properties: {
        foo: {
          oneOf: [{ type: 'string' }, { type: 'integer' }],
          required: true
        }
      },
      type: :object
    )
  end
end
