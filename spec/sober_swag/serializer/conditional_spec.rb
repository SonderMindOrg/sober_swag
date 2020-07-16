require 'spec_helper'

RSpec.describe SoberSwag::Serializer::Conditional do
  context 'with a basic case' do
    let(:left) { SoberSwag::Serializer.Primitive(SoberSwag::Types::Integer) }
    let(:right) { SoberSwag::Serializer.Primitive(SoberSwag::Types::String).via_map(&:to_s) }
    let(:chooser_proc) do
      proc { |val, _opt| val.even? ? [:left, val] : [:right, val] }
    end
    let(:serializer) { described_class.new(chooser_proc, left, right) }

    it 'serializes the left case' do
      expect(serializer.serialize(2)).to eq(2)
    end

    it 'serializes the right case' do
      expect(serializer.serialize(3)).to eq('3')
    end

    context 'with an invalid chooser' do
      subject { proc { described_class.new(chooser_proc, left, right).serialize(10) } }

      let(:chooser_proc) { proc { |val, _| [:foo, val] } }

      it { should raise_error(SoberSwag::Error) }
      it { should raise_error(described_class::BadChoiceError) }
    end
  end
end
