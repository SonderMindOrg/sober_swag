require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Converting::Integer do
  subject { described_class }

  it { should parse_input('10').to(10) }
  it { should parse_input(10).to(10) }
  it { should report_on_input('1123adsklfasjkldf') }
end
