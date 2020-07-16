require 'spec_helper'

RSpec.describe SoberSwag::Serializer::Primitive do
  context 'with a string' do
    let(:serializer) { described_class.new(SoberSwag::Types::String) }

    it 'serializes' do
      expect(serializer.serialize('I am a string')).to eq('I am a string')
    end

    it 'has the right type' do
      expect(serializer.type).to eq(SoberSwag::Types::String)
    end
  end

  context 'when chained with .array' do
    let(:serializer) { described_class.new(SoberSwag::Types::String).array }

    it 'serializes' do
      expect(serializer.serialize(%w[foo bar])).to eq(%w[foo bar])
    end
  end
end
