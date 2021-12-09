require 'spec_helper'

RSpec.describe SoberSwag::Reporting::Input::Struct do
  let(:struct_class) do
    Class.new(described_class) do
      identifier 'Person'

      attribute :first_name, SoberSwag::Reporting::Input::Text.new
      attribute :last_name, SoberSwag::Reporting::Input::Text.new
    end
  end

  let(:nested_class) do
    sk = struct_class
    Class.new(described_class) do
      identifier 'JobPosition'

      attribute :title, SoberSwag::Reporting::Input.text
      attribute :person, sk
    end
  end

  context 'with a basic first/last name' do
    subject { struct_class }

    it { should parse_input({ first_name: 'foo', last_name: 'bar' }).to(have_attributes(first_name: 'foo', last_name: 'bar')) }

    describe 'parsed result with extra attrs' do
      subject { struct_class.call!(first_name: 'foo', last_name: 'bar', other: 'yes') }

      its(:to_h) { should eq({ first_name: 'foo', last_name: 'bar' }) }
      its(:first_name) { should eq 'foo' }
      its(:last_name) { should eq 'bar' }
    end

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

  context 'with nested structs' do
    describe 'parsed result' do
      let(:attributes) do
        {
          title: 'Cool job',
          person: {
            first_name: 'Bob',
            last_name: 'Smith',
            other: 10
          },
          whatever: 10
        }
      end

      subject do
        nested_class.call!(attributes)
      end

      it { should be_a(nested_class) }
      it { should be == nested_class.call!(attributes) }
      its(:person) { should be_a(struct_class) }
      its(:title) { should eq 'Cool job' }
      its([:person]) { should be_a(struct_class) }
      its([:title]) { should eq 'Cool job' }

      its(:to_h) do
        should eq(
          {
            title: 'Cool job',
            person: {
              first_name: 'Bob',
              last_name: 'Smith'
            }
          }
        )
      end

      it 'can be used as a hash key' do
        expect({ subject => 10 }).to eq({ nested_class.call!(attributes) => 10 })
      end
    end
  end
end
