require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Described do
  subject(:input_object) { described_class.new(SoberSwag::Reporting::Input.number, 'my description') }

  it { should parse_input(10).to(10) }

  describe '#swagger_schema[0]' do
    subject { input_object.swagger_schema[0] }

    it { should be_key(:description) }
  end
end
