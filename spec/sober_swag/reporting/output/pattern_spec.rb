require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Pattern do
  subject(:output) do
    described_class.new(
      SoberSwag::Reporting::Output.text,
      /^(foo|bar|\d+)$/
    )
  end

  it { should serialize_output('foo').to('foo') }
  it { should serialize_output('bar').to('bar') }
  it { should report_on_output('foo1') }

  describe '#swagger_schema[0]' do
    subject { output.swagger_schema[0] }

    its([:pattern]) { should be_a(String) & include('^(foo|bar|\\d+)$') }
    its([:type]) { should eq 'string' }
  end
end
