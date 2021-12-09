require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Mapped do
  subject(:input) { described_class.new(SoberSwag::Reporting::Input.number, proc { |x| x * 2 }) }

  it { should parse_input(10).to(20) }
  it { should parse_input(0).to(0) }
  it { should report_on_input('10') }
  its(:swagger_schema) { should eq SoberSwag::Reporting::Input.number.swagger_schema }
end
