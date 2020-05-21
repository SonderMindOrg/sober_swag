require 'spec_helper'

RSpec.describe SoberSwag::Compiler::Type do
  module Types
    include Dry::Types()
  end

  def create_class(&block)
    Class.new(Dry::Struct, &block)
  end

  def self.compiling(&block)
    let(:klass) { create_class(&block) }
    let(:compiler) { described_class.new(klass) }
    subject { compiler }
  end

  context 'with a primitive-only class' do
    compiling do
      attribute? :foo, Types::String
      attribute? :bar, Types::Integer
      attribute :baz, Types::Bool.optional # optional bool, allows empty value
      attribute :mike, Types::Bool
    end

    it 'parses as path schema' do
      expect { subject.path_schema }.to_not raise_error
    end

    it 'parses as querry schema' do
      expect { subject.query_schema }.to_not raise_error
    end

    it 'parses as object schema' do
      expect { subject.object_schema }.to_not raise_error
    end

    describe 'as path schema' do
      subject { compiler.path_schema }
      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: 'integer' })) }
      it { should include(include(schema: { type: 'string' })) }
      it do
        should include(
          include(schema: { type: 'boolean' }, allowEmptyValue: false)
        )
      end
      it do
        should include(
          include(schema: { type: 'boolean' }, allowEmptyValue: true)
        )
      end
    end
  end

  context 'with a class that has enums' do
    compiling do
      attribute :foo, Types::String.enum('foo', 'bar', 'baz')
    end

    it 'parses as path schema' do
      expect { subject.path_schema }.to_not raise_error
    end

    it 'parses as query schema' do
      expect { subject.query_schema }.to_not raise_error
    end

    it 'parses as object schema' do
      expect { subject.object_schema }.to_not raise_error
    end

    describe 'as path schema' do
      subject { compiler.path_schema }
      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: :string, enum: %w[foo bar baz] })) }
    end
  end
end
