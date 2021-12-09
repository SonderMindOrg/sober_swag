require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Number do
  it { should parse_input(10).to(10) }
  it { should report_on_input('10').with_message(match(/number/)) }
end
