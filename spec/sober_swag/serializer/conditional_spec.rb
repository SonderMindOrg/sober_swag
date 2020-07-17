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

  describe '#lazy_type?' do
    subject { described_class.new(chooser, left, right) }

    let(:chooser) { spy }
    let(:left) { spy }
    let(:right) { spy }

    it 'is true if left is true but right is not' do
      allow(left).to receive(:lazy_type?).and_return(true)
      allow(right).to receive(:lazy_type?).and_return(false)

      expect(subject).to be_lazy_type
    end

    it 'is true if right is true but left is not' do
      allow(left).to receive(:lazy_type?).and_return(false)
      allow(right).to receive(:lazy_type?).and_return(true)

      expect(subject).to be_lazy_type
    end

    it 'is true if left is true and right is true' do
      allow(left).to receive(:lazy_type?).and_return(true)
      allow(right).to receive(:lazy_type?).and_return(true)

      expect(subject).to be_lazy_type
    end

    it 'is false if left is false and right is false' do
      allow(left).to receive(:lazy_type?).and_return(false)
      allow(right).to receive(:lazy_type?).and_return(false)

      expect(subject).not_to be_lazy_type
    end
  end

  %i[type lazy_type].each do |meth|
    describe "##{meth}" do
      subject { described_class.new(chooser, left, right) }

      let(:chooser) { spy }
      let(:left) { spy.tap { |s| allow(s).to receive(meth).and_return(SoberSwag::Types::Integer) } }
      let(:right) { spy }

      it 'is the sum of the types if they are different' do
        allow(right).to receive(meth).and_return(SoberSwag::Types::String)
        expect(subject.send(meth)).to eq(SoberSwag::Types::Integer | SoberSwag::Types::String)
      end

      it 'is just the one type if they are the same' do
        allow(right).to receive(meth).and_return(SoberSwag::Types::Integer)
        expect(subject.send(meth)).to eq(SoberSwag::Types::Integer)
      end
    end
  end

  describe '#finalize_lazy_type!' do
    subject { described_class.new(chooser, left, right).finalize_lazy_type! }

    let(:left) { spy }
    let(:right) { spy }
    let(:chooser) { spy }

    it 'calls finalize_lazy_type! on the left serializer' do
      subject
      expect(left).to have_received(:finalize_lazy_type!)
    end

    it 'calls finalize_lazy_type! on the right serializer' do
      subject
      expect(right).to have_received(:finalize_lazy_type!)
    end
  end
end
