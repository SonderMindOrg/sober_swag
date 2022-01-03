require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Object do
  context 'when empty' do
    subject(:input) { described_class.new({}) }

    it { should parse_input({}).to({}) }
    it { should parse_input({ foo: 'bar' }).to({}) }

    describe '#swagger_schema' do
      subject { input.swagger_schema }

      its([0]) { should be_a(Hash) }
      its([1]) { should be_a(Hash) }
    end
  end
end
