require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Struct do
  context 'with a basic first/last name' do
    subject(:struct_class) do
      Class.new(described_class) do
        attribute :first_name, SoberSwag::Reporting::Input::Text.new
        attribute :last_name, SoberSwag::Reporting::Input::Text.new
      end
    end

    it { should parse_input({ first_name: 'foo', last_name: 'bar' }).to(have_attributes(first_name: 'foo', last_name: 'bar')) }
  end
end
