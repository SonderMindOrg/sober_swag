require 'spec_helper'

RSpec.describe SoberSwag::Compiler do
  context 'with a mapped nested output' do
    let(:output) do
      SoberSwag::OutputObject.define do
        ut = primitive(:String).via_map do |t|
          Time.at(t).iso8601
        end
        field :created_at, ut do |r|
          r.internal_data['created_at']
        end
        field :updated_at, ut.optional do |r|
          r.internal_data['updated_at']
        end
      end
    end

    it 'works without error' do
      expect {
        described_class.new.add_type(output.type)
      }.not_to raise_error
    end
  end

  context 'with a metadata output type' do
    subject(:swagger) { compiler.to_swagger }

    let(:output_a) do
      SoberSwag::OutputObject.define do
        identifier 'Student'

        field :name, primitive(:String)
        field :id, primitive(:String)
      end
    end

    let(:output_b) do
      ob = output_a
      SoberSwag::OutputObject.define do
        identifier 'Classroom'

        field :students, ob.view(:base).meta(description: 'All the students in class')
        field :name, primitive(:String)
      end
    end
    let(:compiler) { described_class.new.add_type(output_b.type) }

    describe 'object schemas' do
      subject { swagger.dig(:components, :schemas) }

      it { should have_key('Student') }
      it { should have_key('Classroom') }
      it { should_not have_key('') }
    end
  end
end
