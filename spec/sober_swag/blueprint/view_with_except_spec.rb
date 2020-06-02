require 'spec_helper'

RSpec.describe 'A SoberSwag::Blueprint with a view that uses except' do
  let(:target) { { id: 1, name: 'Anthony' } }
  let(:blueprint) do
    SoberSwag::Blueprint.define do
      sober_name 'Base'
      field :id, primitive(:Integer)
      view :only_name do
        except! :id
        field :name, primitive(:String)
      end
    end
  end

  describe 'the blueprint' do
    subject { blueprint }
    it { should respond_to(:serialize) }
    it { should respond_to(:type) }
    it { should have_attributes(type: be_a(Dry::Struct::Sum)) }
  end

  describe 'serializing' do
    context 'with the view' do
      subject { blueprint.serialize(target, { view: :only_name }) }
      it { should be_a(Hash) }
      it { should have_key(:name) }
      it { should_not have_key(:id) }
      it 'roundtrips' do
        expect { blueprint.type.call(subject) }.to_not raise_error
        expect(blueprint.type.call(subject)).to be_a(blueprint.view(:only_name).type)
      end
    end

    context 'without the view' do
      subject { blueprint.serialize(target) }
      it { should be_a(Hash) }
      it { should have_key(:id) }
      it { should_not have_key(:name) }
      it 'roundtrips' do
        expect { blueprint.type.call(subject) }.to_not raise_error
        expect(blueprint.type.call(subject)).to be_a(blueprint.base.type)
      end
    end
  end
end
