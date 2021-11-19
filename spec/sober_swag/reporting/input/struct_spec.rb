require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Struct do
  context 'with a basic first/last name' do
    subject(:struct_class) do
      Class.new(described_class) do
        identifier 'Person'

        attribute :first_name, SoberSwag::Reporting::Input::Text.new
        attribute :last_name, SoberSwag::Reporting::Input::Text.new
      end
    end

    it { should parse_input({ first_name: 'foo', last_name: 'bar' }).to(have_attributes(first_name: 'foo', last_name: 'bar')) }

    context 'with inheritence' do
      subject(:inherited) do
        Class.new(struct_class) do
          identifier 'AlienPerson'

          attribute :head_count, SoberSwag::Reporting::Input::Number.new
        end
      end

      describe 'parsed result with good stuff' do
        subject(:parsed) do
          inherited.call({ first_name: 'Ajkq', last_name: 'Zzzrp', head_count: 10 })
        end

        it { should_not be_a(SoberSwag::Reporting::Report::Base) }
        its(:first_name) { should eq 'Ajkq' }
        its(:last_name) { should eq 'Zzzrp' }
        its(:head_count) { should eq 10 }
      end
    end
  end
end
