require 'spec_helper'

RSpec.describe SoberSwag::Nodes::Primitive do
  describe 'comparison/equality ops' do
    it 'is equal if the values are equal' do
      expect(described_class.new(1)).to eq(described_class.new(1))
    end
  end

  describe 'mapping' do
    subject { node.map(&block) }

    let(:node) { described_class.new(1) }
    let(:block) { proc { |x| x + 1 } }

    it { should be_a(described_class) }
    it { should_not equal(node) }
    it { should have_attributes(value: 2) }
  end
end
