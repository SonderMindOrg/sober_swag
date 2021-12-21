require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::List do
  subject(:input) { described_class.new(SoberSwag::Reporting::Input::Number.new) }

  it { should parse_input([]).to([]) }
  it { should parse_input([1, 2, 3]).to([1, 2, 3]) }
  it { should report_on_input(['foo']) }
  it { should report_on_input([1, 2, '3']) }

  describe '#swagger_schema[0]' do
    subject { input.swagger_schema[0] }

    its([:type]) { should eq 'list' }
    its([:items]) { should be_a(Hash) & include(type: 'number') }
  end
end
