require 'spec_helper'

RSpec.describe 'compilation integration round-tripping' do
  def self.define_spec_class(&block)
    subject { compile_def(example_class) }

    let(:example_class) { Class.new(Dry::Struct, &block) }
  end

  def self.result(arg)
    it { should eq(arg) }
  end

  def compile_def(klass)
    SoberSwag::Compiler.new.add_type(klass).schema_for(klass)
  end

  describe 'a basic case' do # rubocop:disable RSpec/EmptyExampleGroup
    define_spec_class do
      attribute :foo, SoberSwag::Types::String
    end

    result(
      properties: {
        foo: {
          type: 'string'
        }
      },
      required: [:foo],
      type: :object
    )
  end

  describe 'a case involving optional attributes' do # rubocop:disable RSpec/EmptyExampleGroup
    define_spec_class do
      attribute? :foo, SoberSwag::Types::String
    end

    result(
      properties: {
        foo: { type: 'string' }
      },
      required: [],
      type: :object
    )
  end

  describe 'with a case involving sum types' do # rubocop:disable RSpec/EmptyExampleGroup
    define_spec_class do
      attribute :foo, SoberSwag::Types::String | SoberSwag::Types::Integer
    end
    result(
      properties: {
        foo: {
          oneOf: [{ type: 'string' }, { type: 'integer' }]
        }
      },
      required: [:foo],
      type: :object
    )
  end
end
