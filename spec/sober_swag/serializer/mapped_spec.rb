require 'spec_helper'

RSpec.describe SoberSwag::Serializer::Mapped do
  describe '.via_map' do
    subject { mapped.via_map { |e| e + 3 } }

    let(:initial) { SoberSwag::Serializer.Primitive(:Integer) }
    let(:mapped) { initial.via_map { |e| e * 2 } }

    it 'removes a layer of indirection via proc composition' do
      expect(subject).to have_attributes(base: initial)
    end

    it 'composes in the right order' do
      expect(subject.serialize(3)).to eq(9)
    end

    it { should have_attributes(lazy_type: initial.lazy_type) }
    it { should have_attributes(type: initial.type) }
    it { should have_attributes(lazy_type?: initial.lazy_type?) }
  end
end
