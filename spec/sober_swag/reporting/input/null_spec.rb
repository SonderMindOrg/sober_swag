require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Null do
  it { should parse_input(nil).to(be_nil) }
  it { should report_on_input('foo').with_message(match(/nil/)) }
end
