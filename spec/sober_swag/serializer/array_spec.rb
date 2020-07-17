require 'spec_helper'

RSpec.describe SoberSwag::Serializer::Array do
  let(:element_serializer) { spy }
  let(:injected) { described_class.new(element_serializer) }

  describe '#lazy_type?' do
    it 'delegates to the element' do
      injected.lazy_type?
      expect(element_serializer).to have_received(:lazy_type?)
    end
  end

  describe '#lazy_type' do
    before { allow(element_serializer).to receive(:lazy_type).and_return(SoberSwag::Types::Integer) }

    it 'delegates to the element serializer' do
      injected.lazy_type
      expect(element_serializer).to have_received(:lazy_type)
    end

    it 'returns an array wrapper around the element serializer' do
      expect(injected.lazy_type).to eq(SoberSwag::Types::Array.of(SoberSwag::Types::Integer))
    end
  end

  describe '#finalize_lazy_type!' do
    it 'delegates to the element serializer' do
      injected.finalize_lazy_type!
      expect(element_serializer).to have_received(:finalize_lazy_type!)
    end
  end

  describe '#serialize' do
    it 'delegates to the inner serializer' do
      injected.serialize([1], { foo: :bar })
      expect(element_serializer).to have_received(:serialize).with(1, { foo: :bar })
    end
  end
end
