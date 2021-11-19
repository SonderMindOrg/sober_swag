require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Converting::Date do
  let(:date) { Date.new(2020, 1, 1) }

  subject { described_class }

  it 'converts 8601' do
    expect(subject).to parse_input(date.iso8601).to(date)
  end

  it 'converts rfc3339' do
    expect(subject).to parse_input(date.rfc3339).to(date)
  end
end
