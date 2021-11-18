require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Output::Struct do
  context 'with an output with views' do
    let(:input_type) { Struct.new(:first_name, :last_name) }

    subject(:output) do
      Class.new(described_class) do
        identifier 'Person'

        field(:first_name, SoberSwag::Reporting::Output::Text.new)
        field(:last_name, SoberSwag::Reporting::Output::Text.new)

        define_view :detail do
          field(
            :initials,
            SoberSwag::Reporting::Output::Text.new,
            description: 'does not handle hyphenation, consider this deprecated please'
          ) do |o|
            [o.first_name, o.last_name].map { |i| "#{i[0..0]}." }.join(' ')
          end
        end
      end
    end

    its(:views) { should contain_exactly(:base, :detail) }
    it { should serialize_output(input_type.new('Bob', 'Smith')).to({ first_name: 'Bob', last_name: 'Smith' }) }

    describe 'swagger direct schema' do
      subject(:schema) { output.swagger_schema.first }

      it { should be_key(:$ref) }
    end

    describe 'referenced swagger schemas' do
      subject(:references) do
        SoberSwag::Reporting::Compiler::Schema.new.tap { |s|
          s.compile(output)
        }.references
      end

      it { should be_a(Hash) }
      its(:length) { should eq 3 }
      its(:keys) { should contain_exactly('Person', 'Person.Base', 'Person.Detail') }

      describe 'root Person key' do
        subject(:base) { references['Person'] }

        it { should be_key(:oneOf) }

        describe '[:oneOf]' do
          subject { base[:oneOf] }

          it { should all be_key(:$ref) }
          it { should all(have_attributes(values: include(include('#/components/schemas/Person.')))) }
        end
      end

      describe 'Person.Base' do
        subject(:base) { references['Person.Base'] }

        its([:type]) { should eq 'object' }
        its([:required]) { should contain_exactly(:first_name, :last_name) }
      end

      describe 'Person.Detail' do
        subject(:base) { references['Person.Detail'] }

        it { should be_key(:allOf) }

        describe '[:allOf]' do
          subject { base[:allOf] }

          it { should include("$ref": end_with('Person.Base')) }
          it { should include(include(type: 'object', properties: be_key(:initials))) }
        end
      end
    end
  end
end
