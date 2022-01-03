require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Enum do
  context 'with strings of either "bob" or "joe"' do
    subject(:serializer) do
      described_class.new(SoberSwag::Reporting::Output.text, %w[bob joe])
    end

    it { should serialize_output('bob') }
    it { should serialize_output('joe') }
    it { should report_on_output('rich evans') }
    its(:swagger_schema) { should be_a(Array) & all(be_a(Hash)) }
  end
end
