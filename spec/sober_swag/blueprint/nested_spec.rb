require 'spec_helper'

RSpec.describe 'a nested SoberSwag::Blueprint' do
  let(:person_blueprint) do
    SoberSwag::Blueprint.define do
      field :id, primitive(:Integer)
      field :name, primitive(:String)
    end
  end

  let(:company_blueprint) do
    pb = person_blueprint
    SoberSwag::Blueprint.define do
      field :id, primitive(:Integer)
      field :ceo, pb
    end
  end

  describe 'the returned class' do
    subject { company_blueprint }
    it { should be_a(Class) }
    it { should be_const_defined(:Base) }
  end

  describe 'serializing' do
    let(:target) { { id: 1, ceo: { id: 1, name: 'Mark' } } }

    it 'does so without error' do
      expect { company_blueprint.new.serialize(target) }.to_not raise_error
    end
    it 'serializes properly' do
      expect(company_blueprint.new.serialize(target)).to eq(target)
    end
    it 'roundtrips' do
      expect {
        company_blueprint.type.new(company_blueprint.serializer.serialize(target))
      }.to_not raise_error
    end
  end
end
