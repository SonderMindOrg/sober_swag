require 'spec_helper'

RSpec.describe SoberSwag::Compiler::Type do
  def self.compiling(&block)
    subject { compiler } # rubocop:disable RSpec/MultipleSubjects

    let(:klass) { SoberSwag.input_object(&block) }
    let(:compiler) { described_class.new(klass) }
  end

  def self.compiling_output(&block)
    subject { compiler }

    let(:output) { SoberSwag::OutputObject.define(&block) }
    let(:compiler) { described_class.new(output.type) }
  end

  shared_examples 'a universal type' do
    it 'parses as path schema' do
      expect { subject.path_schema }.not_to raise_error
    end

    it 'parses as querry schema' do
      expect { subject.query_schema }.not_to raise_error
    end

    it 'parses as object schema' do
      expect { subject.object_schema }.not_to raise_error
    end
  end

  context 'with a primitive-only class' do
    compiling do
      attribute? :foo, SoberSwag::Types::String
      attribute? :bar, SoberSwag::Types::Integer
      attribute :baz, SoberSwag::Types::Bool
      attribute :mike, SoberSwag::Types::Bool
    end

    it_behaves_like 'a universal type'

    describe 'as path schema' do
      subject { compiler.path_schema }

      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: 'integer' })) }
      it { should include(include(schema: { type: 'string' })) }

      it do
        expect(subject).to include(
          include(schema: { type: 'boolean' })
        )
      end
    end
  end

  context 'with a class that has an optional mapped type' do
    compiling_output do
    end

    describe 'as object schema' do
      subject { compiler.object_schema }

      specify { expect { subject }.not_to raise_error }
    end
  end

  context 'with a class that has enums' do
    compiling do
      attribute :foo, SoberSwag::Types::String.enum('foo', 'bar', 'baz')
    end

    it_behaves_like 'a universal type'

    describe 'as path schema' do
      subject { compiler.path_schema }

      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: :string, enum: %w[foo bar baz] })) }
    end
  end

  context 'with a class that has default-value enums' do
    compiling do
      attribute :foo, SoberSwag::Types::String.default('foo'.freeze).enum('foo', 'bar', 'baz')
    end

    it_behaves_like 'a universal type'

    describe 'as a path schema' do
      subject { compiler.path_schema }

      it { should all(include(in: :path)) }
      it { should include(include(schema: { type: :string, enum: %w[foo bar baz] }, required: false)) }
    end
  end

  context 'with a class that has sum types' do
    compiling do
      attribute :model, SoberSwag::Types::String | SoberSwag::Types::Integer # maybe it's like an int or a model code
    end

    it_behaves_like 'a universal type'
  end

  context 'with a class that has arrays' do
    compiling do
      attribute :aliases, SoberSwag::Types::Array.of(SoberSwag::Types::String)
    end

    it 'parses as a type schema' do
      expect { subject.path_schema }.not_to raise_error
    end

    it 'parses as a query schema' do
      expect { subject.query_schema }.not_to raise_error
    end

    it 'parses as an object schema' do
      expect { subject.object_schema }.not_to raise_error
    end
  end

  context 'with a class that has descriptions' do
    compiling do
      attribute :icd_code, SoberSwag::Types::String.meta(description: "Called 'idc codes' internally sometimes beacuse of a typo long ago")
    end

    it_behaves_like 'a universal type'
  end

  context 'with a class with various nullable and optional combinations' do
    compiling do
      attribute? :name, primitive(:String)
      attribute :favorite_food, primitive(:String) | primitive(:Integer).optional
      attribute? :other_thing, primitive(:String).optional
    end

    it_behaves_like 'a universal type'
  end

  context 'with a class that has nested things' do
    ExampleInput = SoberSwag.input_object do # rubocop:disable RSpec/LeakyConstantDeclaration
      identifier 'ExampleInput'
      attribute :first_name, SoberSwag::Types::String
    end

    compiling do
      attribute :person, ExampleInput
    end

    it 'cannot compile to a path' do
      expect { subject.path_schema }.to raise_error(SoberSwag::Compiler::Type::TooComplicatedError)
    end

    it 'can compile to a query' do
      expect { subject.query_schema }.not_to raise_error
    end

    it 'compiles to an object schema' do
      expect { subject.object_schema }.not_to raise_error
    end
  end

  context 'with a weird sum of sums type' do
    subject(:compiler) { described_class.new(type) }

    let(:type) do
      (SoberSwag::Types::String | SoberSwag::Types::Integer) |
        (SoberSwag::Types::Integer | SoberSwag::Types::DateTime)
    end

    describe 'object schema' do
      subject { compiler.object_schema }

      it 'raises no error' do
        expect { subject }.not_to raise_error
      end

      it { should be_key(:oneOf) }
      it { should include(oneOf: be_a(Array) & have_attributes(length: 3)) }
      it { should include(oneOf: include(type: 'integer')) }
      it { should include(oneOf: include(type: 'string')) }
    end
  end

  context 'with a `(type | type) | type` type' do
    subject(:compiler) { described_class.new(type) }

    let(:type) { (SoberSwag::Types::String | SoberSwag::Types::Integer) | SoberSwag::Types::Integer }

    describe 'object schema' do
      subject { compiler.object_schema }

      it 'raises no error' do
        expect { subject }.not_to raise_error
      end

      it { should be_key(:oneOf) }
      it { should include(oneOf: be_a(Array) & have_attributes(length: 2)) }
      it { should include(oneOf: include(type: 'string') & include(type: 'integer')) }
    end
  end

  describe 'schema stub' do
    subject { described_class.new(type).schema_stub }

    describe 'with a named type' do
      let(:type) do
        SoberSwag.input_object do
          identifier 'Test'
          attribute :foo, primitive(:String)
        end
      end

      it { should include(:$ref => '#/components/schemas/Test') }
    end

    describe 'with an array type' do
      let(:type) { SoberSwag::Types::Array.of(SoberSwag::Types::String) }

      it { should include(type: :array) }
      it { should include(items: { type: 'string' }) }
    end

    describe 'with a primitive type' do
      let(:type) { SoberSwag::Types::String }

      it { should include(type: 'string') }
    end

    describe 'with a sum type' do
      let(:type) { SoberSwag::Types::String | SoberSwag::Types::Integer }

      it { should be_key(:oneOf) }
      it { should include(oneOf: be_a(Array)) }
      it { should include(oneOf: include(type: 'string')) }
      it { should include(oneOf: include(type: 'integer')) }
    end

    describe 'with a bad argument' do
      let(:type) { 'Bad' }

      it 'raises an error' do
        expect { subject }.to raise_error(SoberSwag::Compiler::Error)
      end
    end
  end
end
