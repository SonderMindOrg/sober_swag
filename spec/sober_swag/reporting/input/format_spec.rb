require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Format do
  subject(:input) { described_class.new(SoberSwag::Reporting::Input.number, 'decimal') }

  it { should parse_input(10) }
  it { should parse_input(100.0) }

  describe '#swagger_schema[0]' do
    subject { input.swagger_schema[0] }

    its([:type]) { should eq 'number' }
    its([:format]) { should eq 'decimal' }
  end
end
