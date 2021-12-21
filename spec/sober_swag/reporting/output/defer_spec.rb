require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Defer do
  let(:mock_object) do
    spy('MockObject').tap do |s| # rubocop:disable RSpec/VerifiedDoubles
      allow(s).to receive(:output).and_return(SoberSwag::Reporting::Output::Number.new)
    end
  end

  subject { described_class.new(proc { mock_object.output }) }

  its(:swagger_schema) { should eq SoberSwag::Reporting::Output.number.swagger_schema }

  context 'when not calling anything' do
    it 'does not call the nested output' do
      subject
      expect(mock_object).not_to have_received(:output)
    end
  end

  context 'when calling multiple times' do
    it { should serialize_output(10).to(10) }

    it 'only calls the block once' do
      2.times { subject.call(10) }
      expect(mock_object).to have_received(:output).once
    end
  end
end
