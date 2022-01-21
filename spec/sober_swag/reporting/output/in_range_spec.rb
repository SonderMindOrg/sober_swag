require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::InRange do
  context 'with a basic range that excludes end' do
    subject(:output) { described_class.new(SoberSwag::Reporting::Output.number, (1...3)) }

    it { should serialize_output(1) }
    it { should serialize_output(2) }
    it { should report_on_output(0) }
    it { should report_on_output(3) }

    describe 'swagger_schema' do
      subject { output.swagger_schema[0] }

      its([:minimum]) { should eq 1 }
      its([:exclusiveMinimum]) { should be_nil | eq(false) }
      its([:maximum]) { should eq 3 }
      its([:exclusiveMaximum]) { should eq true }
    end
  end

  context 'with a range with no maximum' do
    subject(:output) { described_class.new(SoberSwag::Reporting::Output.number, (0..)) }

    it { should serialize_output(0) }
    it { should serialize_output(1) }
    it { should report_on_output(-1) }

    describe 'swagger_schema' do
      subject { output.swagger_schema[0] }

      its([:minimum]) { should eq 0 }
      its([:exclusiveMinimum]) { should be_nil | eq(false) }
      its([:maximum]) { should be_nil }
      its([:exclusiveMaximum]) { should be_nil }
    end
  end
end
