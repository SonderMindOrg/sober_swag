require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Converting::Bool do
  subject { described_class }

  (%w[true yes y t].flat_map { |x| [x, x.upcase] } + ['1', 1, true]).each do |true_input|
    it { should parse_input(true_input).to(true) }
  end

  (%w[false no n f].flat_map { |x| [x, x.upcase] } + ['0', 0, false]).each do |false_input|
    it { should parse_input(false_input).to(false) }
  end
end
