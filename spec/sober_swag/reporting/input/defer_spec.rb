require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Defer do
  let(:mock_object) do
    spy('MockObject').tap do |s| # rubocop:disable RSpec/VerifiedDoubles
      allow(s).to receive(:parser).and_return(SoberSwag::Reporting::Input::Number.new)
    end
  end

  subject { described_class.new(proc { mock_object.parser }) }

  context 'when not calling anything' do
    it 'does not call the number' do
      subject
      expect(mock_object).not_to have_received(:parser)
    end
  end

  context 'when calling multiple times' do
    it { should parse_input(10).to(10) }

    it 'only calls the block once' do
      2.times { subject.call(10) }
      expect(mock_object).to have_received(:parser).once
    end
  end
end
