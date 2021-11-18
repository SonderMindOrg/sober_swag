require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::List do
  context 'with inner text' do
    subject { described_class.new(SoberSwag::Reporting::Output::Text.new) }

    its(:views) { should contain_exactly(:base) }
    it { should serialize_output([]).to([]) }
    it { should serialize_output(%w[foo bar]).to(%w[foo bar]) }

    it do
      expect(subject).to serialize_output(
        %w[foo bar].to_set
      ).to(
        contain_exactly('foo', 'bar')
      )
    end

    it { should report_on_output(nil) }
    it { should report_on_output(['foo', nil]) }

    its(:swagger_schema) do
      should match([{ type: 'array', items: { type: 'string' } }, be_empty])
    end
  end
end
