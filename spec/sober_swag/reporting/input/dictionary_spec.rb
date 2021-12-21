require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Dictionary do
  subject(:input) { described_class.new(SoberSwag::Reporting::Input.number.mapped { |x| x * 2 }) }

  it { should parse_input({ a: 1, b: 2 }).to({ a: 2, b: 4 }) }
  it { should parse_input({}).to({}) }
  it { should report_on_input({ a: 1, b: 'foo' }) }

  describe '#swagger_schema[0]' do
    subject { input.swagger_schema[0] }

    its([:additionalProperties]) { should be_a(Hash) }
    its([:type]) { should eq :object }
  end
end
