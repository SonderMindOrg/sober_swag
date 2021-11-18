require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Either do
  context 'with a text or a null' do
    subject { SoberSwag::Reporting::Input::Null.new | SoberSwag::Reporting::Input::Text.new }

    it { should parse_input(nil).to(nil) }
    it { should parse_input('foo').to('foo') }
    it { should report_on_input(1).with_message(match(/nil/)) }
    it { should report_on_input(1).with_message(match(/string/)) }
  end
end
