require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Number do
  it { should serialize_output(BigDecimal('10.0')) }
  it { should serialize_output(10) }
  it { should report_on_output('foo') }
  it { should report_on_output('10') }
end
