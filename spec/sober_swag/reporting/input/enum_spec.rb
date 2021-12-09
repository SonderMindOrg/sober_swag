require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Enum do
  subject(:input) { described_class.new(SoberSwag::Reporting::Input.text, %w[foo bar baz]) }

  it { should parse_input('foo') }
  it { should report_on_input('whatever') }

  describe '#swagger_schema[0]' do
    subject { input.swagger_schema[0] }

    its([:type]) { should eq 'string' }
    its([:enum]) { should be_a(Array) & contain_exactly('foo', 'bar', 'baz') }
  end
end
