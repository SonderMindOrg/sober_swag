require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::MultipleOf do
  context 'with a multiple of 2' do
    subject(:input) { SoberSwag::Reporting::Input.number.multiple_of(2) }

    it { should parse_input(2) }
    it { should parse_input(4) }
    it { should report_on_input(1) }
    it { should report_on_input(3.5) }

    its(:swagger_schema) { should all(be_a(Hash)) }

    describe '#swagger_schema[0]' do
      subject { input.swagger_schema[0] }

      its([:multipleOf]) { should eq 2 }
    end
  end
end
