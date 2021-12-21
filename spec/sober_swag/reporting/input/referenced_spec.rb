require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Referenced do
  subject(:input) do
    described_class.new(
      SoberSwag::Reporting::Input.text,
      'MyText'
    )
  end

  it { should parse_input('test text').to('test text') }

  describe '#swagger_schema' do
    subject { input.swagger_schema }

    its([0]) { should be_key(:"$ref") & include({ "$ref": end_with('MyText') }) }
    its([1]) { should include('MyText' => be_a(Proc)) }
  end
end
