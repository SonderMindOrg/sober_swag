require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Null do
  it { should serialize_output(nil) }
  it { should report_on_output(false) }
  it { should report_on_output(0) }
end
