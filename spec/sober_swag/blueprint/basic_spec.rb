require 'spec_helper'

RSpec.describe 'a basic SoberSwag::Blueprint' do
  let(:blueprint) do
    SoberSwag::Blueprint.define do
      sober_name 'BasicBlueprint'
      field :id, primitive(:Integer)
      field :name, primitive(:String)
    end
  end

  it 'is a class' do
    expect(blueprint).to respond_to(:serialize) & respond_to(:type)
  end

  it 'has a Base constant defined' do
    expect(blueprint).to have_attributes(sober_name: 'BasicBlueprint')
  end

  it 'serializes without error' do
    expect {
      blueprint.serialize({id: 1, name: 'Anthony'})
    }.to_not raise_error
  end

  it 'serializes properly' do
    expect(blueprint.serialize({id: 1, name: 'Anthony'})).to eq(id: 1, name: 'Anthony')
  end

  describe 'roundtripping' do
    let(:roundtripped) do
      blueprint.type.new(blueprint.serialize({id: 1, name: 'Anthony'}))
    end

    it 'works' do
      expect { roundtripped }.to_not raise_error
    end

    it 'is the right type' do
      expect(roundtripped).to be_a(blueprint.base.type)
    end
  end
end
