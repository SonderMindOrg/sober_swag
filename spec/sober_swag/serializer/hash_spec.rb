require 'spec_helper'

RSpec.describe SoberSwag::Serializer::Hash do
  context 'with a basic empty-hash case' do
    let(:default) { SoberSwag::Serializer.primitive(SoberSwag::Types::Integer) }
    let(:key_proc) { proc { |_, _| '' } }
    let(:cases) { {} }

    subject(:serializer) { described_class.new(cases, default, key_proc) }

    it { should_not be_lazy_type }
    its(:possible_serializers) { should contain_exactly(default) }
    its(:type) { should be default.type }
  end

  describe '.finalize_lazy_type!' do
    it 'works with a hash' do
      val_spy = spy
      default_spy = spy

      described_class.new({ 'foo' => val_spy }, default_spy, proc {}).finalize_lazy_type!

      aggregate_failures do
        expect(val_spy).to have_received(:finalize_lazy_type!)
        expect(default_spy).to have_received(:finalize_lazy_type!)
      end
    end

    it 'works with only a default' do
      default_spy = spy

      described_class.new({}, default_spy, proc {}).finalize_lazy_type!
      expect(default_spy).to have_received(:finalize_lazy_type!)
    end
  end
end
