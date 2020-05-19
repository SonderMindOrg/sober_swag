require 'spec_helper'

RSpec.describe SoberSwag::Nodes::Binary do
  describe 'equality/comparison' do
    it 'is eq by the elements' do
      expect(described_class.new(1, 2)).to eq(described_class.new(1, 2))
    end
  end

  describe 'mapping' do
    let(:node) { described_class.new([1], [2]) }
    let(:block) { proc { |x| x + 1 } }
    subject { node.map(&block) }
    it { should be_a(described_class) }
    it { should have_attributes(lhs: [2], rhs: [3]) }
    it { should_not equal(node) }
  end
end
