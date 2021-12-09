require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::ViaMap do
  subject(:output) do
    described_class.new(
      SoberSwag::Reporting::Output.number,
      proc { |x| x * 2 }
    )
  end

  it { should serialize_output(10).to(20) }
  it { should report_on_output('10') }

  its(:swagger_schema) { should eq SoberSwag::Reporting::Output.number.swagger_schema }
  its(:views) { should eq SoberSwag::Reporting::Output.number.views }
end
