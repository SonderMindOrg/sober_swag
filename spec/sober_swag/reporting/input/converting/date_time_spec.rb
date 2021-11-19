require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Converting::DateTime do
  let(:time) { DateTime.new }

  subject { described_class }

  it 'parses iso8601' do
    expect(subject).to parse_input(time.iso8601).to(time)
  end

  it 'parses rfc3339' do
    expect(subject).to parse_input(time.rfc3339).to(time)
  end

  it 'does not parse junk' do
    expect(subject).to report_on_input('my birthday').with_message(match(/rfc/is))
  end
end
