require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Text do
  its(:views) { should contain_exactly(:base) }
  it { should serialize_output('str').to('str') }
  it { should report_on_output(10) }
  it { should report_on_output(nil) }

  its(:swagger_schema) do
    should match([{ type: 'string' }, be_empty])
  end
end
