require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Pattern do
  subject(:input) do
    described_class.new(
      SoberSwag::Reporting::Input.text,
      /^(foo|bar|\d+)$/
    )
  end

  it { should parse_input('foo').to('foo') }
  it { should parse_input('123').to('123') }
  it { should report_on_input('foo1') }

  describe '#swagger_schema[0]' do
    subject { input.swagger_schema[0] }

    its([:type]) { should eq 'string' }
    its([:pattern]) { should eq '(^(foo|bar|\\d+)$)' }
  end
end
