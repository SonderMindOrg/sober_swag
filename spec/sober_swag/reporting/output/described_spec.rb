require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Described do
  context 'with a text' do
    subject { described_class.new(SoberSwag::Reporting::Output::Text.new, 'test') }

    its(:views) { should contain_exactly(:base) }
    it { should serialize_output('foo').to('foo') }

    its(:swagger_schema) do
      should match([{ type: 'string', description: 'test' }, be_empty])
    end
  end
end
