require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Partitioned do
  context 'with a string or nilable number partition' do
    subject(:output) do
      SoberSwag::Reporting::Output::Number.new.partitioned(
        SoberSwag::Reporting::Output::Text.new
      ) { |input| input.is_a?(Numeric) }.nilable
    end

    it { should serialize_output('foo') }
    it { should serialize_output(10.0) }
    it { should serialize_output(nil) }
    it { should report_on_output([]) }

    describe 'schema' do
      subject(:schema) { output.swagger_schema.first }

      it { should be_key(:oneOf) }
      its([:oneOf]) { should be_a(Array) & all(be_key(:type)) }
    end
  end
end
