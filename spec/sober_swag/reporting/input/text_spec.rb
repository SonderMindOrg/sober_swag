require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Text do
  it { should parse_input('').to('') }
  it { should parse_input('foo').to('foo') }
  it { should report_on_input(10).with_message(match(/string/)) }
end
