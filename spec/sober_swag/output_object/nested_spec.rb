require 'spec_helper'

RSpec.describe 'a nested SoberSwag::OutputObject' do
  let(:target) { { id: 1, ceo: { id: 1, name: 'Mark' } } }

  let(:person_output_object) do
    SoberSwag::OutputObject.define do
      identifier 'Person'
      field :id, primitive(:Integer)
      field :name, primitive(:String)
    end
  end

  let(:company_output_object) do
    pb = person_output_object
    SoberSwag::OutputObject.define do
      identifier 'Company'
      field :id, primitive(:Integer)
      field :ceo, pb
    end
  end

  describe 'the returned serializer' do
    subject { company_output_object }

    it { should respond_to(:serialize) }
    it { should respond_to(:type) }
    it { should respond_to(:base) }
  end

  describe 'serializing' do
    it 'does so without error' do
      expect { company_output_object.serialize(target) }.not_to raise_error
    end

    it 'serializes properly' do
      expect(company_output_object.serialize(target)).to eq(target)
    end

    it 'roundtrips' do
      expect {
        company_output_object.type.new(company_output_object.serialize(target))
      }.not_to raise_error
    end
  end
end
