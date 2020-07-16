require 'spec_helper'

RSpec.describe SoberSwag::Compiler::Type do
  def self.compiling(&block)
    subject { compiler }

    let(:klass) { SoberSwag.input_object(&block) }
    let(:compiler) { described_class.new(klass) }
  end

  context 'with a primitive-only class' do
    compiling do
      attribute? :foo, SoberSwag::Types::String
      attribute? :bar, SoberSwag::Types::Integer
      attribute :baz, SoberSwag::Types::Bool.optional # optional bool, allows empty value
      attribute :mike, SoberSwag::Types::Bool
    end

    it 'parses as path schema' do
      expect { subject.path_schema }.not_to raise_error
    end

    it 'parses as querry schema' do
      expect { subject.query_schema }.not_to raise_error
    end

    it 'parses as object schema' do
      expect { subject.object_schema }.not_to raise_error
    end

    describe 'as path schema' do
      subject { compiler.path_schema }

      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: 'integer' })) }
      it { should include(include(schema: { type: 'string' })) }

      it do
        expect(subject).to include(
          include(schema: { type: 'boolean' }, allowEmptyValue: false)
        )
      end

      it do
        expect(subject).to include(
          include(schema: { type: 'boolean' }, allowEmptyValue: true)
        )
      end
    end
  end

  context 'with a class that has enums' do
    compiling do
      attribute :foo, SoberSwag::Types::String.enum('foo', 'bar', 'baz')
    end

    it 'parses as path schema' do
      expect { subject.path_schema }.not_to raise_error
    end

    it 'parses as query schema' do
      expect { subject.query_schema }.not_to raise_error
    end

    it 'parses as object schema' do
      expect { subject.object_schema }.not_to raise_error
    end

    describe 'as path schema' do
      subject { compiler.path_schema }

      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: :string, enum: %w[foo bar baz] })) }
    end
  end
end
