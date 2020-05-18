require 'spec_helper'

RSpec.describe 'A SoberSwag::Blueprint with a view that uses except' do
  let(:blueprint) do
    SoberSwag::Blueprint.define do
      field :id, primitive(:Integer)
      view :only_name do
        except! :id
        field :name, primitive(:String)
      end
    end
  end

  describe 'the blueprint' do
    subject { blueprint }
    it { should be_a(Class) }
    it { should have_attributes(ancestors: include(SoberSwag::Serializer::Base)) }
    it { should be_const_defined(:Base) }
    it { should be_const_defined(:OnlyName) }
  end

  describe 'serializing' do
    let(:target) { { id: 1, name: 'Anthony' } }
    context 'with the view' do
      subject { blueprint.new.serialize(target, { view: :only_name }) }
      it { should be_a(Hash) }
      it { should have_key(:name) }
      it { should_not have_key(:id) }
      it 'roundtrips' do
        expect(blueprint.new.type.call(subject)).to be_a(blueprint::OnlyName)
      end
    end

    context 'without the view' do
      subject { blueprint.new.serialize(target) }
      it { should be_a(Hash) }
      it { should have_key(:id) }
      it { should_not have_key(:name) }
      it 'roundtrips' do
        expect(blueprint.new.type.call(subject)).to be_a(blueprint::Base)
      end
    end
  end
end
