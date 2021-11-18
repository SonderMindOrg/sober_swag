require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Referenced do
  context 'when wrapped around text' do
    subject(:output) do
      described_class.new(SoberSwag::Reporting::Output::Text.new, 'MyText')
    end

    describe 'the direct schema' do
      subject { output.swagger_schema[0] }

      it { should be_key(:$ref) }
      its([:$ref]) { should eq '#/components/schemas/MyText' }
    end

    describe 'the found schema' do
      subject { output.swagger_schema[1] }

      its(:keys) { should contain_exactly('MyText') }
      its(:values) { should all be_a(Proc) }
    end
  end
end
