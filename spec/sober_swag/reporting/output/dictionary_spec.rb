require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Dictionary do
  subject(:output) { described_class.of(SoberSwag::Reporting::Output.number.via_map { |x| x * 2 }) }

  it { should serialize_output({ foo: 1 }).to({ foo: 2 }) }
  it { should report_on_output({ foo: 'Bar' }) }

  describe '#swagger_schema[0]' do
    subject { output.swagger_schema[0] }

    its([:type]) { should eq :object }
    its([:additionalProperties]) { should be_a(Hash) }
  end
end
