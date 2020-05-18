require 'spec_helper'

RSpec.describe 'a basic SoberSwag::Blueprint' do
  let(:blueprint) do
    SoberSwag::Blueprint.define do
      field :id, primitive(:Integer)
      field :name, primitive(:String)
    end
  end

  it 'is a class' do
    expect(blueprint).to be_a(Class)
  end

  it 'has a Base constant defined' do
    expect(blueprint).to be_const_defined(:Base)
  end

  it 'serializes without error' do
    expect {
      blueprint.new.serialize({id: 1, name: 'Anthony'})
    }.to_not raise_error
  end

  it 'serializes properly' do
    expect(blueprint.new.serialize({id: 1, name: 'Anthony'})).to eq(id: 1, name: 'Anthony')
  end

  it 'roundtrips' do
    expect {
      blueprint.new.type.new(blueprint.new.serialize({id: 1, name: 'Anthony'}))
    }.to_not raise_error
  end
end
