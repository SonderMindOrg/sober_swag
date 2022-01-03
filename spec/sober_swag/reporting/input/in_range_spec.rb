require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::InRange do
  context 'with a simple integer range that excludes end' do
    subject(:input) { described_class.new(SoberSwag::Reporting::Input.number, (1...3)) }

    it { should parse_input(1) }
    it { should parse_input(2) }
    it { should report_on_input(0) }
    it { should report_on_input(3) }

    describe '#swagger_schema[0]' do
      subject { input.swagger_schema[0] }

      its([:minimum]) { should eq 1 }
      its([:exclusiveMinimum]) { should be_nil | eq(false) }
      its([:maximum]) { should eq 3 }
      its([:exclusiveMaximum]) { should eq(true) }
    end
  end
end
