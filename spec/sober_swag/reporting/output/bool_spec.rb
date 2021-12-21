require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Bool do
  it { should serialize_output(true) }
  it { should serialize_output(false) }
  it { should report_on_output(10) }
  it { should report_on_output('true') }
end
