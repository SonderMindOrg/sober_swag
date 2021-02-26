require 'spec_helper'

RSpec.describe SoberSwag::Compiler::Primitive do
  subject { described_class.new(type) }

  context 'with a non-class' do
    specify { expect { described_class.new(1) }.to raise_error(SoberSwag::Compiler::Error) }
  end

  context 'with an input object' do
    let(:type) { SoberSwag.input_object { identifier 'Wow' } }

    it { should_not be_swagger_primitive }
    it { should be_named }
    it { should have_attributes(type_hash: { oneOf: [{ '$ref'.to_sym => '#/components/schemas/Wow' }] }) }
  end

  context 'with a string' do
    let(:type) { String }

    it { should be_swagger_primitive }
    it { should_not be_named }
    it { should have_attributes(type_hash: { type: :string }) }
  end

  context 'with a time' do
    let(:type) { Time }

    it { should be_swagger_primitive }
    it { should_not be_named }
    it { should have_attributes(type_hash: { type: :string, format: :'date-time' }) }
  end

  context 'with a hash' do
    let(:type) { Hash }

    it { should be_swagger_primitive }
    it { should_not be_named }
    it { should have_attributes(type_hash: { type: :object, additionalProperties: true }) }
  end
end
